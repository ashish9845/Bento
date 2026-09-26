import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final extractControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(persistenceKey: 'extract', processFn: (inputs, ctrl) async {
    final selected = ref.read(extractSelectionProvider).toList();
    if (selected.isEmpty) throw Exception('Tap pages to select at least one');
    ctrl.setProgress(null, 'Extracting ${selected.length} pages…');
    final out = await repo.extractPages(inputs.first, selected, outputName: ctrl.outputName);
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

    Future<void> pickFile() async {
      // Drop stale selection — page indices belong to the previous file.
      ref.read(extractSelectionProvider.notifier).state = {};
      await ctrl.pickFiles(allowedExtensions: const ['pdf']);
    }

    void toggle(int i) {
      final current = ref.read(extractSelectionProvider);
      if (current.contains(i)) {
        ref.read(extractSelectionProvider.notifier).state = {...current}..remove(i);
      } else {
        ref.read(extractSelectionProvider.notifier).state = {...current, i};
      }
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
            onPick: pickFile,
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
                    onTap: toggle,
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
          if (state.hasResult)
            ToolSuccess(
              message: 'Extracted ${selected.length} pages',
              onOpen: () => openDoc(context, state.resultFiles.first.path),
              onShare: ctrl.shareResult,
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: state.files.isEmpty || selected.isEmpty || state.isProcessing
                  ? null
                  : () => runWithRename(
                      context: context, ctrl: ctrl, defaultName: defaultOutputName('Extracted')),
              icon: const Icon(Icons.filter_none),
              label: const Text('Extract')),
        ],
      ),
    );
  }
}
