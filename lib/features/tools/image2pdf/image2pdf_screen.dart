import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

Future<Uint8List> _buildPdfIsolate(List<String> paths) async {
  final pdf = pw.Document();
  for (final p in paths) {
    final bytes = await File(p).readAsBytes();
    final image = pw.MemoryImage(bytes);
    pdf.addPage(pw.Page(
      build: (ctx) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
    ));
  }
  return pdf.save();
}

final image2pdfControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  return ToolController(processFn: (inputs, ctrl) async {
    ctrl.setProgress(null, 'Creating PDF from ${inputs.length} images…');
    // Run heavy PDF build off main thread to keep 60fps
    final paths = inputs.map((f) => f.path).toList();
    final outBytes = await Isolate.run(() => _buildPdfIsolate(paths));
    final temp = await getTemporaryDirectory();
    final docs = await getApplicationDocumentsDirectory();
    String saveDir = docs.path;
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString('storage_location');
      if (custom != null && await Directory(custom).exists()) saveDir = custom;
    } catch (_) {}
    final name = 'images_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final tempFile = File('${temp.path}/$name');
    await tempFile.writeAsBytes(outBytes);
    final docFile = File('$saveDir/$name');
    await docFile.writeAsBytes(outBytes);
    return [tempFile];
  });
});

class Image2PdfScreen extends ConsumerWidget {
  const Image2PdfScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(image2pdfControllerProvider);
    final ctrl = ref.read(image2pdfControllerProvider.notifier);
    return ToolScaffold(
      title: 'Image → PDF',
      subtitle: 'Pick images and compose into a PDF',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowMultiple: true,
            allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
            label: 'Images (${state.files.length})',
            onPick: () => ctrl.pickFiles(allowMultiple: true, allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']),
            onClear: ctrl.clearFiles,
          ),
          if (state.files.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.files
                    .map((f) => Chip(
                          label: Text(f.path.split('/').last, overflow: TextOverflow.ellipsis),
                          avatar: const Icon(Icons.image_outlined, size: 18),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Converting…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ...[
            ToolSuccess(message: 'PDF created — also saved to Documents', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: state.resultFiles.map((f) => ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(f.path.split('/').last),
                      subtitle: Text(f.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.picture_as_pdf), label: const Text('Create PDF')),
        ],
      ),
    );
  }
}
