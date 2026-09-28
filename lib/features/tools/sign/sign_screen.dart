import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

double _signWidth(String size) {
  switch (size) {
    case 'small':
      return 100;
    case 'large':
      return 180;
    default:
      return 140;
  }
}

class SignScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  late final ToolCubit _cubit;
  final List<Offset> _points = [];

  /// While a stroke is in progress, page scrolling is locked so the
  /// signature pad — not the page — receives the drag.
  bool _drawing = false;

  /// Actual pad width in logical pixels (full available width). Points are
  /// recorded in this same space, so rasterizing at this width is 1:1 —
  /// nothing is clipped on wide screens.
  double _padWidth = 300;

  Uint8List? _sigBytes;
  int _page = 0;
  String _size = 'medium';
  Future<int>? _pageCountFuture;
  String? _pageCountPath;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'sign',
      processFn: (inputs, ctrl) async {
        final sigBytes = _sigBytes;
        if (sigBytes == null) {
          throw Exception('Draw and save your signature first');
        }
        ctrl.setProgress(null, 'Stamping signature onto page ${_page + 1}…');
        final out = await repository.signPdf(
          inputs.first,
          signaturePng: sigBytes,
          page: _page,
          widthPts: _signWidth(_size),
          outputName: ctrl.outputName,
        );
        return [out];
      },
    );
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  void _onFilesChanged(ToolState state) {
    final path = state.files.isEmpty ? null : state.files.first.path;
    if (path != _pageCountPath) {
      setState(() {
        _pageCountPath = path;
        _pageCountFuture = path == null ? null : _cubit.pageCount(File(path));
        _page = 0;
      });
    }
  }

  Future<Uint8List> _rasterize() async {
    final w = _padWidth > 0 ? _padWidth : 300.0;
    const h = 150.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] != Offset.zero && _points[i + 1] != Offset.zero) {
        canvas.drawLine(_points[i], _points[i + 1], paint);
      }
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _pickFile() async {
    await _cubit.pickFiles(allowedExtensions: const ['pdf']);
    setState(() => _page = 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ToolCubit, ToolState>(
        listener: (context, state) => _onFilesChanged(state),
        builder: (context, state) {
          final sigBytes = _sigBytes;
          final hasSig = sigBytes != null;

          return ToolScaffold(
            title: 'Sign PDF',
            subtitle: 'Your signature is stamped onto the original pages — content is preserved.',
            physics: _drawing ? const NeverScrollableScrollPhysics() : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to sign',
                  onPick: _pickFile,
                  onClear: _cubit.clearFiles,
                ),
                const SizedBox(height: 12),
                if (state.files.isNotEmpty && _pageCountFuture != null)
                  FutureBuilder<int>(
                    future: _pageCountFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Text('Could not read page count: ${snap.error}');
                      }
                      final count = snap.data ?? 0;
                      final page = _page.clamp(0, count > 0 ? count - 1 : 0);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Placement',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton.filledTonal(
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                    onPressed: page <= 0
                                        ? null
                                        : () =>
                                              setState(() => _page = page - 1),
                                    tooltip: 'Previous page',
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Page ${page + 1} of $count',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    onPressed: page >= count - 1
                                        ? null
                                        : () =>
                                              setState(() => _page = page + 1),
                                    tooltip: 'Next page',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Size',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'small',
                                    label: Text('Small'),
                                  ),
                                  ButtonSegment(
                                    value: 'medium',
                                    label: Text('Medium'),
                                  ),
                                  ButtonSegment(
                                    value: 'large',
                                    label: Text('Large'),
                                  ),
                                ],
                                selected: {_size},
                                showSelectedIcon: false,
                                onSelectionChanged: (s) =>
                                    setState(() => _size = s.first),
                                style: SegmentedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stamped bottom-right, aspect preserved',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (state.files.isNotEmpty) const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signature',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            // Paper white is intentional for signature ink visibility in both themes
                            color: const Color(0xFFFFFFFF),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Remember the real width (no setState needed — only read at rasterize time).
                              _padWidth = constraints.maxWidth;
                              return Listener(
                                onPointerDown: (_) =>
                                    setState(() => _drawing = true),
                                onPointerUp: (_) =>
                                    setState(() => _drawing = false),
                                onPointerCancel: (_) =>
                                    setState(() => _drawing = false),
                                child: GestureDetector(
                                  onPanUpdate: (d) => setState(
                                    () => _points.add(d.localPosition),
                                  ),
                                  onPanEnd: (_) => setState(() {
                                    _points.add(Offset.zero);
                                    _drawing = false;
                                  }),
                                  child: CustomPaint(
                                    painter: _SigPainter(_points),
                                    size: Size(constraints.maxWidth, 150),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => setState(_points.clear),
                              child: const Text('Clear'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                if (_points.isEmpty) return;
                                final bytes = await _rasterize();
                                if (mounted) {
                                  setState(() => _sigBytes = bytes);
                                }
                              },
                              child: const Text('Save signature'),
                            ),
                            const Spacer(),
                            if (hasSig)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                          ],
                        ),
                        if (hasSig) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.visibility_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Saved — this is what will be stamped:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 72,
                            width: double.infinity,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              // Paper white matches the stamped PNG background
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Image.memory(sigBytes, fit: BoxFit.contain),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.isProcessing)
                  ToolProgress(label: state.message ?? 'Signing…'),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Signed!',
                    onOpen: () =>
                        openDoc(context, state.resultFiles.first.path),
                    onShare: _cubit.shareResult,
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      state.files.isEmpty || !hasSig || state.isProcessing
                      ? null
                      : () {
                          final stem = state.files.first.path
                              .split('/')
                              .last
                              .replaceAll(
                                RegExp(r'\.pdf$', caseSensitive: false),
                                '',
                              );
                          final fallback = stem.isEmpty
                              ? 'Signed'
                              : '${stem}_signed';
                          unawaited(
                            runWithRename(
                              context: context,
                              ctrl: _cubit,
                              defaultName: fallback,
                            ),
                          );
                        },
                  icon: const Icon(Icons.draw_outlined),
                  label: const Text('Apply signature'),
                ),
                if (state.files.isNotEmpty && !hasSig)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Draw your signature and tap “Save signature” first',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SigPainter extends CustomPainter {
  new(this.points);
  final List<Offset> points;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SigPainter old) => old.points != points;
}
