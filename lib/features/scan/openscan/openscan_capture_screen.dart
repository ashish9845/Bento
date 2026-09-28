import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'cv/models/detection_result.dart';
import 'cv/models/point.dart';
import 'cv/models/quad.dart';
import 'cv/document_detector.dart';
import 'cv/perspective_crop.dart';
import 'filters/filters/document_filters.dart';
import 'filters/filters/filters.dart';

/// OpenScan capture flow: camera photo → boundary detection → YOU crop it
/// manually (draggable corners, seeded with the detected boundary) →
/// document filter → preview. Supports continuous multi-page sessions.
/// Pops with `List<String>` of ready JPEG paths for the Scan review flow.
///
/// ARCH NOTE (strict REPO/DATA <-> BLOC <-> UI): camera + `compute`
/// isolates intentionally stay in this UI screen — they are hardware-bound
/// (`CameraController` lifecycle, viewfinder preview, `takePicture`) and
/// frame-coupled (crop-editor gestures, filter preview). Session
/// persistence, ML Kit capture, permissions, and PDF export live in the
/// Scan cubits; this screen only returns JPEG paths to the Scan screen, which
/// dispatches them to its session cubit.
class OpenScanCaptureScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<OpenScanCaptureScreen> createState() => _OpenScanCaptureScreenState();
}

enum _Stage { preview, working, crop, done, error }

class _OpenScanCaptureScreenState extends State<OpenScanCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _initError;
  _Stage _stage = _Stage.preview;
  String? _status;
  String? _error;

  /// Downscaled working image (≤2000px) every later step operates on.
  Uint8List? _workImage;
  int _workW = 0;
  int _workH = 0;

  /// Current crop quad in working-image pixels (null until a shot is ready).
  Quad? _workQuad;

  /// Quad last applied (reused when switching filters in preview).
  Quad? _appliedQuad;

  /// Currently previewed (cropped + filtered) page.
  String? _previewPath;

  /// Accepted pages this session (filtered files, kept on disk).
  final List<String> _sessionPaths = [];

  Filter _filter = OriginalFilter();
  bool _flashOn = false;
  bool _applyingFilter = false;

  static const _filters = <String>['Original', 'Grayscale', 'B&W'];

  bool _isSelected(String name) =>
      _filter.name == name || (name == 'B&W' && _filter is BlackAndWhiteFilter);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initCamera());
  }

  /// The camera feed dies when the app is backgrounded (black preview on
  /// return, seen on MIUI/HyperOS). Release it while away, re-open on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (controller != null) {
        _controller = null;
        unawaited(controller.dispose());
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && _initError == null && mounted) {
        unawaited(_initCamera());
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      // Guard against a camera service that never answers (seen headless).
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Camera did not respond'),
      );
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _initError = 'No camera found on this device');
        }
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on Exception catch (e) {
      debugPrint('[OpenScan] camera init failed: $e');
      if (mounted) {
        setState(
          () => _initError =
              'Camera unavailable on this device. '
              'Check permission and try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      _flashOn = !_flashOn;
      await controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    } on Exception catch (_) {}
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _stage == _Stage.working) {
      return;
    }
    _discardCurrent();
    setState(() {
      _stage = _Stage.working;
      _status = 'Capturing…';
      _error = null;
    });
    try {
      final photo = await controller.takePicture();
      final tempDir = await getTemporaryDirectory();
      if (!mounted) return;
      setState(() => _status = 'Finding document edges…');
      final prepared = await compute(_prepareEditorEntry, {
        'path': photo.path,
        'tempDir': tempDir.path,
      });
      if (!mounted) return;
      setState(() {
        _workImage = prepared['image'] as Uint8List;
        _workW = prepared['width'] as int;
        _workH = prepared['height'] as int;
        _workQuad = prepared['quad'] as Quad;
        _appliedQuad = null;
        _stage = _Stage.crop;
      });
      if (prepared['foundQuad'] != true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No edges detected — adjust the corners yourself'),
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _stage = _Stage.error;
      });
    }
  }

  /// Crops with [quad] (working-image pixels) and applies the current filter.
  Future<void> _applyCrop(Quad quad) async {
    final workImage = _workImage;
    if (workImage == null) return;
    setState(() {
      _stage = _Stage.working;
      _status = 'Cropping…';
      _error = null;
    });
    try {
      final tempDir = await getTemporaryDirectory();
      if (!mounted) return;
      _appliedQuad = quad;
      setState(() => _status = 'Applying ${_filter.name} filter…');
      final next = await compute(_cropAndFilterEntry, {
        'image': workImage,
        'quad': quad,
        'filter': _filter.name,
        'tempDir': tempDir.path,
      });
      final previous = _previewPath;
      if (!mounted) return;
      setState(() {
        _previewPath = next;
        _stage = _Stage.done;
      });
      if (previous != null && previous != next) {
        unawaited(File(previous).delete().catchError((_) => File(previous)));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _stage = _Stage.error;
      });
    }
  }

  /// Re-renders the preview (and final file) from the applied crop whenever
  /// the filter changes. Fast single-image op on working-size bytes.
  Future<void> _onFilterSelected(String name) async {
    if (_stage == _Stage.working || _applyingFilter) return;
    setState(() => _filter = _filterForName(name));
    final quad = _appliedQuad;
    final workImage = _workImage;
    if (quad == null || workImage == null) return;
    setState(() => _applyingFilter = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (!mounted) return;
      final next = await compute(_cropAndFilterEntry, {
        'image': workImage,
        'quad': quad,
        'filter': _filter.name,
        'tempDir': tempDir.path,
      });
      final previous = _previewPath;
      if (!mounted) return;
      setState(() => _previewPath = next);
      if (previous != null && previous != next) {
        unawaited(File(previous).delete().catchError((_) => File(previous)));
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _applyingFilter = false);
    }
  }

  /// Adds the current page to the session and returns to the live viewfinder
  /// for continuous capture. The filtered file is kept as the session entry.
  void _addPage() {
    final preview = _previewPath;
    if (preview == null) return;
    setState(() {
      _sessionPaths.add(preview);
      _previewPath = null;
      _workImage = null;
      _workQuad = null;
      _appliedQuad = null;
      _stage = _Stage.preview;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_sessionPaths.length} page(s) — keep scanning or tap Use',
        ),
      ),
    );
  }

  void _retake() {
    _discardCurrent();
    setState(() => _stage = _Stage.preview);
  }

  void _usePages() {
    final pages = [..._sessionPaths];
    if (_previewPath != null) {
      // Current preview becomes the last page; ownership passes to the caller.
      pages.add(_previewPath!);
      _previewPath = null;
      _workImage = null;
    }
    Navigator.pop(context, pages);
  }

  void _close() {
    // Backing out keeps already-accepted session pages instead of losing them.
    Navigator.pop(context, _sessionPaths.isEmpty ? null : [..._sessionPaths]);
  }

  void _discardCurrent() {
    final preview = _previewPath;
    _previewPath = null;
    if (preview != null && !_sessionPaths.contains(preview)) {
      unawaited(File(preview).delete().catchError((_) => File(preview)));
    }
    _workImage = null;
    _workQuad = null;
    _appliedQuad = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan', style: TextStyle(color: Colors.white)),
        leading: CloseButton(color: Colors.white, onPressed: _close),
        actions: [
          if (_sessionPaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_sessionPaths.length} page${_sessionPaths.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          if (_controller != null)
            IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: Colors.white,
              ),
              tooltip: 'Flash',
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_rounded,
                size: 48,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final showingResult = _stage == _Stage.done && _previewPath != null;
    final editingCrop =
        _stage == _Stage.crop && _workImage != null && _workQuad != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (editingCrop)
                ColoredBox(
                  color: Colors.black,
                  child: _CropEditor(
                    imageBytes: _workImage!,
                    imgW: _workW,
                    imgH: _workH,
                    initialQuad: _workQuad!,
                    onApply: _applyCrop,
                    onSkip: () {
                      final w = _workW.toDouble();
                      final h = _workH.toDouble();
                      unawaited(
                        _applyCrop(
                          Quad(
                            topLeft: const Pt(0, 0),
                            topRight: Pt(w, 0),
                            bottomRight: Pt(w, h),
                            bottomLeft: Pt(0, h),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else if (showingResult)
                Image.file(File(_previewPath!), fit: BoxFit.contain)
              else
                CameraPreview(controller),
              if (!showingResult && !editingCrop && _applyingFilter)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Applying filter…',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Corner guides overlay while aiming.
              if (!showingResult && !editingCrop)
                IgnorePointer(
                  child: CustomPaint(
                    painter: _ViewfinderPainter(),
                    size: Size.infinite,
                  ),
                ),
              if (_stage == _Stage.working)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(_status ?? 'Working…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_error != null)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!editingCrop) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final name in _filters)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: name,
                            selected: _isSelected(name),
                            enabled:
                                _stage != _Stage.working && !_applyingFilter,
                            onTap: () => _onFilterSelected(name),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (editingCrop)
                Text(
                  'Drag the corners to adjust, then Apply crop',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              if (editingCrop) const SizedBox(height: 8),
              if (editingCrop)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final w = _workW.toDouble();
                          final h = _workH.toDouble();
                          unawaited(
                            _applyCrop(
                              Quad(
                                topLeft: const Pt(0, 0),
                                topRight: Pt(w, 0),
                                bottomRight: Pt(w, h),
                                bottomLeft: Pt(0, h),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.crop_free_rounded),
                        label: const Text('Full photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _editorApplyCurrent,
                        icon: const Icon(Icons.crop_rounded),
                        label: const Text('Apply crop'),
                      ),
                    ),
                  ],
                )
              else if (showingResult)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _retake,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retake'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _addPage,
                            icon: const Icon(Icons.library_add_rounded),
                            label: const Text('Add page'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _usePages,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        _sessionPaths.isEmpty
                            ? 'Use this page'
                            : 'Use ${_sessionPaths.length + 1} pages',
                      ),
                    ),
                  ],
                )
              else
                _ShutterButton(
                  key: const ValueKey('openscan_capture_button'),
                  working: _stage == _Stage.working,
                  onTap: _capture,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Applies whatever quad the editor currently holds. The editor reports
  /// changes through `onApply` continuously while dragging.
  void _editorApplyCurrent() {
    final quad = _editorKey.currentState?.quad;
    if (quad != null) unawaited(_applyCrop(quad));
  }

  final _editorKey = GlobalKey<_CropEditorState>();
}

/// Manual crop editor: full photo with a draggable-corner quad overlay,
/// seeded with the auto-detected boundary. Drag a handle to reshape.
class _CropEditor extends StatefulWidget {
  const new({
    required this.imageBytes,
    required this.imgW,
    required this.imgH,
    required this.initialQuad,
    required this.onApply,
    required this.onSkip,
  });

  final Uint8List imageBytes;
  final int imgW;
  final int imgH;
  final Quad initialQuad;
  final ValueChanged<Quad> onApply;
  final VoidCallback onSkip;

  @override
  State<_CropEditor> createState() => _CropEditorState();
}

class _CropEditorState extends State<_CropEditor> {
  late Quad _quad;
  int? _active;

  Quad get quad => _quad;

  @override
  void initState() {
    super.initState();
    _quad = widget.initialQuad;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxW = constraints.maxWidth;
        final boxH = constraints.maxHeight;
        final scale = min(boxW / widget.imgW, boxH / widget.imgH);
        final dispW = widget.imgW * scale;
        final dispH = widget.imgH * scale;
        final ox = (boxW - dispW) / 2;
        final oy = (boxH - dispH) / 2;

        Offset toDisp(Pt p) => Offset(ox + p.x * scale, oy + p.y * scale);
        Pt toImg(Offset p) => Pt(
          ((p.dx - ox) / scale).clamp(0, widget.imgW.toDouble()),
          ((p.dy - oy) / scale).clamp(0, widget.imgH.toDouble()),
        );

        final corners = [
          _quad.topLeft,
          _quad.topRight,
          _quad.bottomRight,
          _quad.bottomLeft,
        ];

        return Center(
          child: SizedBox(
            width: dispW,
            height: dispH,
            child: Stack(
              children: [
                Image.memory(
                  widget.imageBytes,
                  width: dispW,
                  height: dispH,
                  fit: BoxFit.fill,
                ),
                CustomPaint(
                  size: Size(dispW, dispH),
                  painter: _QuadPainter(_quad, scale),
                ),
                for (var i = 0; i < 4; i++)
                  Positioned(
                    left: toDisp(corners[i]).dx - 28,
                    top: toDisp(corners[i]).dy - 28,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (_) => setState(() => _active = i),
                      onPanUpdate: (d) {
                        final np = toImg(
                          d.localPosition + const Offset(28, 28),
                        );
                        setState(() {
                          final pts = [
                            corners[0],
                            corners[1],
                            corners[2],
                            corners[3],
                          ];
                          pts[i] = np;
                          _quad = Quad(
                            topLeft: pts[0],
                            topRight: pts[1],
                            bottomRight: pts[2],
                            bottomLeft: pts[3],
                          );
                        });
                      },
                      // NOTE: no auto-apply here — the user adjusts all four
                      // corners freely and confirms with Apply crop.
                      onPanEnd: (_) => setState(() => _active = null),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: Container(
                            width: _active == i ? 30 : 24,
                            height: _active == i ? 30 : 24,
                            decoration: BoxDecoration(
                              color: _active == i
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _active == i
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black45, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Quad outline + dimmed surround.
class _QuadPainter extends CustomPainter {
  new(this.quad, this.scale);
  final Quad quad;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [
      Offset(quad.topLeft.x * scale, quad.topLeft.y * scale),
      Offset(quad.topRight.x * scale, quad.topRight.y * scale),
      Offset(quad.bottomRight.x * scale, quad.bottomRight.y * scale),
      Offset(quad.bottomLeft.x * scale, quad.bottomLeft.y * scale),
    ];
    final path = Path()..addPolygon(pts, true);
    canvas.save();
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addPolygon(pts, true)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _QuadPainter old) =>
      old.quad != quad || old.scale != scale;
}

Filter _filterForName(String name) {
  switch (name) {
    case 'Original':
      return OriginalFilter();
    case 'Grayscale':
      return GrayscaleFilter();
    case 'B&W':
      return BlackAndWhiteFilter();
    default:
      return AutoFilter();
  }
}

/// Filter pill: highlighted filled pill when selected, dim gray otherwise.
class _FilterChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label filter',
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary
                : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 15, color: scheme.onPrimary),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? scheme.onPrimary
                      : Colors.white.withValues(alpha: 0.55),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Classic camera shutter: white ring with a solid center. Shows a spinner
/// while the photo is being processed.
class _ShutterButton extends StatelessWidget {
  const new({required this.working, required this.onTap, super.key});

  final bool working;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Capture page',
      button: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: working ? null : onTap,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: working
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Subtle corner guides to help frame the document.
class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const inset = 28.0;
    const len = 34.0;
    final corners = [
      (
        Offset(inset, inset),
        Offset(inset + len, inset),
        Offset(inset, inset + len),
      ),
      (
        Offset(size.width - inset, inset),
        Offset(size.width - inset - len, inset),
        Offset(size.width - inset, inset + len),
      ),
      (
        Offset(inset, size.height - inset),
        Offset(inset + len, size.height - inset),
        Offset(inset, size.height - inset - len),
      ),
      (
        Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - len, size.height - inset),
        Offset(size.width - inset, size.height - inset - len),
      ),
    ];
    for (final (corner, h, v) in corners) {
      canvas.drawLine(corner, h, paint);
      canvas.drawLine(corner, v, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decode once, downscale to a working cap, detect the boundary.
/// Returns working-size JPEG bytes + dimensions + quad (or null).
/// Single decode keeps capture-to-editor latency low.
Future<Map<String, dynamic>> _prepareEditorEntry(
  Map<String, dynamic> params,
) async {
  final path = params['path'] as String;
  final tempDir = params['tempDir'] as String;

  final bytes = await File(path).readAsBytes();
  var decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Could not decode photo');

  const cap = 2000;
  final longest = max(decoded.width, decoded.height);
  if (longest > cap) {
    final s = cap / longest;
    decoded = img.copyResize(
      decoded,
      width: (decoded.width * s).round(),
      height: (decoded.height * s).round(),
    );
  }

  Quad? quad;
  var foundQuad = false;
  final detection = await detectDocumentIsolateEntry(path);
  if (detection is DetectionSuccess) {
    final sx = decoded.width / detection.imageWidth;
    final sy = decoded.height / detection.imageHeight;
    quad = detection.quad.scaled(sx, sy);
    foundQuad = true;
  }
  quad ??= Quad(
    topLeft: Pt(decoded.width * 0.06, decoded.height * 0.06),
    topRight: Pt(decoded.width * 0.94, decoded.height * 0.06),
    bottomRight: Pt(decoded.width * 0.94, decoded.height * 0.94),
    bottomLeft: Pt(decoded.width * 0.06, decoded.height * 0.94),
  );

  final preview = img.encodeJpg(decoded, quality: 85);
  final previewPath =
      '$tempDir/bento_openscan_work_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(previewPath).writeAsBytes(preview, flush: true);
  return {
    'image': Uint8List.fromList(preview),
    'width': decoded.width,
    'height': decoded.height,
    'quad': quad,
    'foundQuad': foundQuad,
  };
}

/// Warps an already-decoded working image with `quad`, filters, writes JPEG.
/// Operates on small working bytes — fast enough for instant filter preview.
Future<String> _cropAndFilterEntry(Map<String, dynamic> params) async {
  final imageBytes = params['image'] as Uint8List;
  final quad = params['quad'] as Quad;
  final filterName = params['filter'] as String;
  final tempDir = params['tempDir'] as String;

  final decoded = img.decodeImage(imageBytes);
  if (decoded == null) throw Exception('Could not decode photo');
  final warped = warpToPage(decoded, quad, maxEdge: 2000);
  final page = warped ?? decoded;
  final rgba = page.getBytes(order: img.ChannelOrder.rgba);
  _filterForName(filterName).apply(rgba, page.width, page.height);
  final out = img.Image.fromBytes(
    width: page.width,
    height: page.height,
    bytes: Uint8List.fromList(rgba).buffer,
    numChannels: 4,
  );
  final dest =
      '$tempDir/bento_openscan_page_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(dest).writeAsBytes(img.encodeJpg(out, quality: 92), flush: true);
  return dest;
}
