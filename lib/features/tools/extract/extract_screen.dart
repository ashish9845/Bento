import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final extractControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    final selected = ref.read(extractSelectionProvider).toList();
    ctrl.setProgress(null, 'Extracting ${selected.length} pages…');
    final out = await repo.extractPages(inputs.first, selected);
    return [out];
  });
});

final extractSelectionProvider = StateProvider<Set<int>>((ref) => {});

class ExtractScreen extends ConsumerWidget {
  const ExtractScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extractControllerProvider);
    final ctrl = ref.read(extractControllerProvider.notifier);
    final selected = ref.watch(extractSelectionProvider);
    final pageCountAsync = state.files.isEmpty
        ? null
        : ref.watch(pdfPageCountProvider(state.files.first.path));

    void clearAll() {
      ref.read(extractSelectionProvider.notifier).state = {};
      ctrl.clearFiles();
    }

    return ToolScaffold(
      title: 'Extract Pages',
      subtitle: 'Tap pages to select, then extract',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to extract from',
            onPick: () => ctrl.pickFiles(allowedExtensions: const ['pdf']),
            onClear: clearAll,
          ),
          const SizedBox(height: 12),
          if (state.files.isNotEmpty)
            pageCountAsync?.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Could not read page count: $e'),
                  data: (count) => PdfThumbnailGrid(
                    pageCount: count,
                    selectedPages: selected,
                    onDelete: (i) {
                      if (selected.contains(i)) {
                        ref.read(extractSelectionProvider.notifier).state = {...selected}..remove(i);
                      } else {
                        ref.read(extractSelectionProvider.notifier).state = {...selected, i};
                      }
                    },
                  ),
                ) ??
                const SizedBox.shrink(),
          if (state.files.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${selected.length} pages selected', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 12),
          if (state.isProcessing) const ToolProgress(label: 'Extracting…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Extracted ${selected.length} pages', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: state.files.isEmpty || selected.isEmpty || state.isProcessing ? null : ctrl.run,
              icon: const Icon(Icons.filter_none),
              label: const Text('Extract')),
        ],
      ),
    );
  }
}
