import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:share_plus/share_plus.dart';

import 'scanner_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _busy = false;
  String? _error;
  File? _pdf;
  List<String> _images = [];

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final svc = ref.read(scannerServiceProvider);
      final images = await svc.scanDocument();
      if (images.isEmpty) {
        // cancelled — don't show error, just inform
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scan cancelled')),
          );
        }
        return;
      }
      // keep images for preview
      setState(() => _images = images);
      ref.read(scanResultsProvider.notifier).state = images;
      final pdf = await svc.imagesToPdf(images);
      setState(() => _pdf = pdf);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned ${images.length} page(s) → PDF ready')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.document_scanner, size: 48),
                    const SizedBox(height: 12),
                    Text('Document scanner',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Capture documents with auto edge detection and cropping.\nTap Scan to open the camera.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _scan,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.camera_alt),
              label: Text(_busy ? 'Scanning…' : 'Scan document'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              ),
            ],
            if (_images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Captured ${_images.length} page(s)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: _images.length,
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_images[i]), fit: BoxFit.cover),
                ),
              ),
            ],
            if (_pdf != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(_pdf!.path.split('/').last),
                  subtitle: Text(_pdf!.path, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.send_outlined), onPressed: () => SendToToolSheet.show(context, _pdf!)),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(_pdf!.path)])),
                    ),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _pdf == null ? null : () => SharePlus.instance.share(ShareParams(files: [XFile(_pdf!.path)])),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
              OutlinedButton.icon(
                onPressed: _pdf == null ? null : () => SendToToolSheet.show(context, _pdf!),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send to tool'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
