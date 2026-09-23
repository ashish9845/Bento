import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/engine/engine_providers.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final mergeControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final bridge = ref.watch(engineBridgeProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    if (bridge == null) {
      ctrl.setProgress(null, 'Engine not ready — using placeholder');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return inputs;
    }
    final out = await bridge.merge(inputs);
    return [out];
  });
});

class MergeScreen extends ConsumerWidget {
  const MergeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mergeControllerProvider);
    final ctrl = ref.read(mergeControllerProvider.notifier);
    final engineReady = ref.watch(engineReadyProvider);

    return ToolScaffold(
      title: 'Merge PDFs',
      subtitle: 'Combine multiple PDFs. Pick 2+ files, reorder via list.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!engineReady)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Engine placeholder'),
                subtitle: Text('Compress spike not yet run — results echo input'),
              ),
            ),
          FilePickerCard(
            files: state.files,
            allowMultiple: true,
            allowedExtensions: const ['pdf'],
            label: 'PDFs to merge (${state.files.length})',
            onPick: () => ctrl.pickFiles(allowMultiple: true, allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          if (state.files.length >= 2)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.files.length,
                  // ignore: deprecated_member_use
                  onReorder: (oldIndex, newIndex) {
                    final files = [...state.files];
                    var adjustedNewIndex = newIndex;
                    if (adjustedNewIndex > oldIndex) adjustedNewIndex--;
                    final item = files.removeAt(oldIndex);
                    files.insert(adjustedNewIndex, item);
                    ctrl.setFiles(files);
                  },
                  itemBuilder: (context, i) => ListTile(
                    key: ValueKey(state.files[i].path),
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(state.files[i].path.split('/').last),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Merging…', progress: state.progress),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult)
            ToolSuccess(
              message: state.message ?? 'Merged!',
              onSave: ctrl.saveToDocuments,
              onShare: ctrl.shareResult,
              onSendTo: () => SendToToolSheet.show(context, state.resultFiles.first),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.files.length < 2 || state.isProcessing ? null : ctrl.run,
            icon: const Icon(Icons.merge),
            label: const Text('Merge'),
          ),
        ],
      ),
    );
  }
}
