import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/engine/engine_providers.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final compressControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final bridge = ref.watch(engineBridgeProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    if (bridge == null) {
      ctrl.setProgress(null, 'Engine placeholder — echoing file');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return inputs;
    }
    final quality = ref.read(compressQualityProvider);
    final out = await bridge.compress(inputs.first, quality: quality);
    return [out];
  });
});

final compressQualityProvider = StateProvider<String>((ref) => 'medium');

class CompressScreen extends ConsumerWidget {
  const CompressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(compressControllerProvider);
    final ctrl = ref.read(compressControllerProvider.notifier);
    final quality = ref.watch(compressQualityProvider);
    final engineReady = ref.watch(engineReadyProvider);

    return ToolScaffold(
      title: 'Compress PDF',
      subtitle: 'Phase 2 spike — Ghostscript/LibreOffice + SharedArrayBuffer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!engineReady)
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: const ListTile(
                leading: Icon(Icons.science_outlined),
                title: Text('Spike mode'),
                subtitle: Text('Engine bundle not yet built — result echoes input. Run vite build then airplane-mode QA.'),
              ),
            ),
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
