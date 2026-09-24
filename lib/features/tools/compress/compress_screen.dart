import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final compressControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    final quality = ref.read(compressQualityProvider);
    ctrl.setProgress(null, 'Compressing (${_qualityLabel(quality)})…');
    final out = await repo.compressPdf(inputs.first, _qualityPolicy(quality));
    return [out];
  });
});

final compressQualityProvider = StateProvider<String>((ref) => 'medium');

PdfImagePolicy _qualityPolicy(String quality) {
  switch (quality) {
    case 'low':
      return PdfImagePolicy.screen; // 72 ppi — smallest files
    case 'high':
      return PdfImagePolicy.lossless; // re-pack streams, no quality loss
    default:
      return PdfImagePolicy.ebook; // 150 ppi — balanced
  }
}

String _qualityLabel(String quality) {
  switch (quality) {
    case 'low':
      return 'high compression';
    case 'high':
      return 'high quality';
    default:
      return 'balanced';
  }
}

class CompressScreen extends ConsumerWidget {
  const CompressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(compressControllerProvider);
    final ctrl = ref.read(compressControllerProvider.notifier);
    final quality = ref.watch(compressQualityProvider);

    return ToolScaffold(
      title: 'Compress PDF',
      subtitle: 'Shrink file size with the native engine — best for scanned & image PDFs.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to compress',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quality', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'low', label: Text('High compression')),
                      ButtonSegment(value: 'medium', label: Text('Balanced')),
                      ButtonSegment(value: 'high', label: Text('High quality')),
                    ],
                    selected: {quality},
                    onSelectionChanged: (s) =>
                        ref.read(compressQualityProvider.notifier).state = s.first,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Compressing…', progress: state.progress),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult)
            ToolSuccess(
              message: 'Compressed! ${state.resultFiles.first.path}',
              onSave: ctrl.saveToDocuments,
              onShare: ctrl.shareResult,
              onSendTo: () => SendToToolSheet.show(context, state.resultFiles.first),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.compress), label: const Text('Compress')),
        ],
      ),
    );
  }
}
