import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan/core/router/route_names.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scanner_service.dart';

class ScanScreen extends StatefulWidget {
  const new({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _busy = false;
  bool _creating = false;
  String? _error;

  /// Full technical detail for the current error (code/message/details/stack).
  /// Shown via the Copy details button so failures can be diagnosed off-device.
  String? _errorDetails;
  bool _permissionError = false;
  File? _pdf;
  List<String> _images = [];

  /// Review pages mirrored here so they survive Android killing the app
  /// while the scanner activity is in front.
  static const _pendingImagesKey = 'scan_pending_images';

  @override
  void initState() {
    super.initState();
    unawaited(_hydrateImages());
  }

  Future<void> _hydrateImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = prefs.getStringList(_pendingImagesKey) ?? const [];
      final existing = paths
          .where((p) => p.isNotEmpty && File(p).existsSync())
          .take(30)
          .toList();
      if (existing.isNotEmpty && mounted) {
        setState(() => _images = existing);
      } else if (existing.length != paths.length) {
        await prefs.setStringList(_pendingImagesKey, existing);
      }
    } on Exception catch (_) {}
  }

  Future<void> _persistImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pendingImagesKey, _images.take(30).toList());
    } on Exception catch (_) {}
  }

  /// Capture pages and append them to the review list — no PDF is created yet.
  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _error = null;
      _errorDetails = null;
      _permissionError = false;
    });
    try {
      if (Platform.isAndroid) {
        // ML Kit uses Play Services' camera permission — no app-level
        // camera prompt needed.
        await _scanWithMlKit();
        return;
      }
      // iOS: OpenScan uses our own camera, so ask up-front — denial shows
      // our guidance instead of failing silently.
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (status.isPermanentlyDenied) {
        setState(() {
          _error =
              'Camera access is blocked. Allow it in system Settings to scan.';
          _permissionError = true;
        });
        return;
      }
      if (!status.isGranted) {
        setState(
          () => _error = 'Camera permission is required to scan documents.',
        );
        return;
      }

      // iOS only: OpenScan capture screen returns cropped, filtered pages
      // (the ML Kit plugin is Android-only).
      await _scanWithOpenScan();
    } on Exception catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// OpenScan capture flow (built-in camera + edge detection). iOS only —
  /// the ML Kit plugin is Android-only, so this is the iOS scanner.
  Future<void> _scanWithOpenScan() async {
    final result = await context.pushNamed<List<String>?>(RouteNames.openscan);
    if (!mounted) return;
    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Scan cancelled')));
      return;
    }
    _appendPages(result);
  }

  void _appendPages(List<String> images) {
    setState(() => _images = [..._images, ...images]);
    unawaited(_persistImages());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${images.length} page(s) added — review below, then create PDF',
        ),
      ),
    );
  }

  /// Android: Google ML Kit document scanner (edge detection, crop, filters
  /// built in). JPEGs flow into the same review list as every other source.
  Future<void> _scanWithMlKit() async {
    // Full mode: filters + enhancements. (A BASE-mode workaround was tried
    // 2026-09-25 for release-build NPEs, but dex forensics proved the NPE
    // came from R8 stripping ML Kit constructors in release builds, not
    // from the scanner mode. R8 is now disabled via shrink=false, so FULL
    // is safe again.)
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: {DocumentFormat.jpeg},
        pageLimit: 10,
        mode: ScannerMode.full,
        isGalleryImport: true,
      ),
    );
    try {
      final res = await scanner.scanDocument();
      if (!mounted) return;
      final images = res.images?.whereType<String>().toList() ?? [];
      if (images.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Scan cancelled')));
        return;
      }
      _appendPages(images);
    } on PlatformException catch (e, s) {
      // The native side reports user cancellation as an error.
      if ((e.message ?? '').toLowerCase().contains('cancel')) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Scan cancelled')));
        }
        return;
      }
      // Capture everything — code, message, native details, Dart stack —
      // so the exact cause can be read off the device via the Copy details
      // button (e.g. "Failed to start document scanner" when Play Services
      // can't provision the ML Kit module).
      final full = StringBuffer()
        ..writeln('Scanner: ML Kit document scanner')
        ..writeln('Code: ${e.code}')
        ..writeln('Message: ${e.message}')
        ..writeln('Details: ${e.details}')
        ..writeln('Dart stack: $s')
        ..writeln(
          'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        );
      debugPrint('[Scan] ML Kit failed:\n$full');
      setState(() {
        _error =
            'ML Kit scanner failed [${e.code}]: ${e.message ?? e.details?.toString() ?? 'unknown error'}';
        _errorDetails = full.toString();
      });
    } finally {
      // Closed separately so a close-time failure can never mask the scan result.
      try {
        await scanner.close();
      } on Exception catch (e) {
        debugPrint('[Scan] scanner.close failed (ignored): $e');
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _images = [..._images]..removeAt(index));
    unawaited(_persistImages());
  }

  /// Ask for a file name, then build the PDF from the reviewed pages.
  Future<void> _createPdf() async {
    if (_images.isEmpty) return;
    final now = DateTime.now();
    final defaultName =
        'Scan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final controller = TextEditingController(text: defaultName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name your scan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'File name',
            hintText: 'MyScan',
            suffixText: '.pdf',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final svc = ScannerService();
      final pdf = await svc.imagesToPdf(_images, outputName: name);
      setState(() => _pdf = pdf);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF created: ${pdf.path.split('/').last}')),
        );
      }
    } on Exception catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
            title: const Text('Scan'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.document_scanner_rounded,
                                size: 32,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Document scanner',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan pages, review and reorder them below,\nthen name your file and create the PDF.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const ValueKey('scan_button'),
                      onPressed: _busy ? null : _scan,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.document_scanner),
                      label: Text(
                        _busy
                            ? 'Scanning…'
                            : (_images.isEmpty
                                  ? 'Scan document'
                                  : 'Add more pages'),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: scheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: scheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: scheme.onErrorContainer,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_permissionError)
                                    FilledButton.tonalIcon(
                                      onPressed: openAppSettings,
                                      icon: const Icon(
                                        Icons.settings_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Open Settings'),
                                    ),
                                  if (_errorDetails != null)
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        unawaited(
                                          Clipboard.setData(
                                            ClipboardData(text: _errorDetails!),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Error details copied — paste them in chat',
                                                ),
                                              ),
                                            );
                                      },
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Copy details'),
                                    ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _scan,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Try again'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Review pages (${_images.length})',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _busy || _creating
                                ? null
                                : () {
                                    setState(() => _images = []);
                                    unawaited(_persistImages());
                                  },
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Clear all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: _images.length,
                        itemBuilder: (context, i) => RepaintBoundary(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_images[i]),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Semantics(
                                  label: 'Remove page ${i + 1}',
                                  button: true,
                                  child: InkWell(
                                    onTap: _creating
                                        ? null
                                        : () => _removeImage(i),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: scheme.errorContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _creating ? null : _createPdf,
                        icon: _creating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded),
                        label: Text(
                          _creating ? 'Creating…' : 'Name & create PDF',
                        ),
                      ),
                    ],
                    if (_pdf != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: scheme.primaryContainer,
                        child: ListTile(
                          leading: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: scheme.onPrimaryContainer,
                          ),
                          title: Text(
                            _pdf!.path.split('/').last,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            _pdf!.path,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_new_rounded),
                                tooltip: 'Open PDF',
                                onPressed: () => openDoc(context, _pdf!.path),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_outlined),
                                tooltip: 'Send to tool',
                                onPressed: () =>
                                    SendToToolSheet.show(context, _pdf!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_rounded),
                                tooltip: 'Share',
                                onPressed: () => SharePlus.instance.share(
                                  ShareParams(files: [XFile(_pdf!.path)]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_pdf != null) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => openDoc(context, _pdf!.path),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(files: [XFile(_pdf!.path)]),
                            ),
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Share'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                SendToToolSheet.show(context, _pdf!),
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Send to tool'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
