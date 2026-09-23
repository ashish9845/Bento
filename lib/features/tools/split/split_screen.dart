import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/engine/engine_providers.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final splitControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final bridge = ref.watch(engineBridgeProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    final input = inputs.first;
    if (bridge == null) return [input];
    // Example ranges: caller should parse from UI; placeholder split into 2
    return bridge.split(input, ['1-1', '2-end']);
  });
});

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});
  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  final _rangesCtrl = TextEditingController(text: '1-1, 2-end');

  @override
  void dispose() {
    _rangesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splitControllerProvider);
    final ctrl = ref.read(splitControllerProvider.notifier);

    return ToolScaffold(
      title: 'Split PDF',
      subtitle: 'Split by ranges, e.g. 1-2, 3, 4-end',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to split',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: ctrl.clearFiles,
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty) ...[
            TextField(
              controller: _rangesCtrl,
              decoration: const InputDecoration(
                labelText: 'Ranges',
                hintText: '1-1, 2-end',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const PdfThumbnailGrid(pageCount: 3),
          ],
          const SizedBox(height: 12),
          if (state.isProcessing) ToolProgress(label: state.message ?? 'Splitting…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Split into ${state.resultFiles.length} file(s)', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.content_cut), label: const Text('Split')),
        ],
      ),
    );
  }
}
