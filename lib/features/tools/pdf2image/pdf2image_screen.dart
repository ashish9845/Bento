import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/engine/engine_providers.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final pdf2imageControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final bridge = ref.watch(engineBridgeProvider);
  return ToolController(processFn: (inputs, _) async {
    if (bridge == null) return inputs;
    return bridge.pdfToImage(inputs.first);
  });
});

class Pdf2ImageScreen extends ConsumerWidget {
  const Pdf2ImageScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdf2imageControllerProvider);
    final ctrl = ref.read(pdf2imageControllerProvider.notifier);
    return ToolScaffold(
      title: 'PDF → Image',
      subtitle: 'Export pages as images',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to export',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.image_outlined),
                const SizedBox(width: 8),
                Text('Format: PNG (engine default)', style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Exporting…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Exported ${state.resultFiles.length} image(s)', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.image), label: const Text('Export')),
        ],
      ),
    );
  }
}
