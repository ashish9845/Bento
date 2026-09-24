import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final organizeControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(processFn: (inputs, ctrl) async {
    final deleted = ref.read(organizeDeleteProvider);
    final rotations = ref.read(organizeRotationsProvider);
    ctrl.setProgress(null, 'Applying changes…');
    final out = await repo.organizePdf(inputs.first, delete: deleted, rotations: rotations);
    return [out];
  });
});

final organizeDeleteProvider = StateProvider<Set<int>>((ref) => {});
final organizeRotationsProvider = StateProvider<Map<int, int>>((ref) => {});

class OrganizeScreen extends ConsumerWidget {
  const OrganizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizeControllerProvider);
    final ctrl = ref.read(organizeControllerProvider.notifier);
    final deleted = ref.watch(organizeDeleteProvider);
    final rotations = ref.watch(organizeRotationsProvider);
    final pageCountAsync = state.files.isEmpty
        ? null
        : ref.watch(pdfPageCountProvider(state.files.first.path));

    void clearAll() {
      ref.read(organizeDeleteProvider.notifier).state = {};
      ref.read(organizeRotationsProvider.notifier).state = {};
      ctrl.clearFiles();
    }

    return ToolScaffold(
      title: 'Organize Pages',
      subtitle: 'Rotate or delete pages, then apply',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to organize',
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
                    selectedPages: deleted,
                    onDelete: (i) {
                      if (deleted.contains(i)) {
                        ref.read(organizeDeleteProvider.notifier).state = {...deleted}..remove(i);
                      } else {
                        ref.read(organizeDeleteProvider.notifier).state = {...deleted, i};
                      }
                    },
                    onRotate: (i) {
                      final next = {...rotations};
                      next[i] = ((next[i] ?? 0) + 90) % 360;
                      if (next[i] == 0) next.remove(i);
                      ref.read(organizeRotationsProvider.notifier).state = next;
                    },
                  ),
                ) ??
                const SizedBox.shrink(),
          if (deleted.isNotEmpty || rotations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Pending: ${deleted.length} deleted, ${rotations.length} rotated',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          if (state.isProcessing) const ToolProgress(label: 'Organizing…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ToolSuccess(message: 'Organized!', onSave: ctrl.saveToDocuments, onShare: ctrl.shareResult),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: state.files.isEmpty || state.isProcessing ? null : ctrl.run, icon: const Icon(Icons.view_carousel_outlined), label: const Text('Apply')),
        ],
      ),
    );
  }
}
