import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/pdf_thumbnail_grid.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final splitControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
      final repo = ref.watch(toolsRepositoryProvider);
      return ToolController(
        persistenceKey: 'split',
        processFn: (inputs, ctrl) async {
          final ranges = ref.read(splitRangesProvider).trim();
          ctrl.setProgress(null, 'Splitting by "$ranges"…');
          return repo.splitPdf(
            inputs.first,
            ranges.isEmpty ? '1-end' : ranges,
            baseName: ctrl.outputName,
          );
        },
      );
    });

final splitRangesProvider = StateProvider<String>((ref) => '1-1, 2-end');

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});
  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  late final TextEditingController _rangesCtrl;

  @override
  void initState() {
    super.initState();
    _rangesCtrl = TextEditingController(text: ref.read(splitRangesProvider));
  }

  @override
  void dispose() {
    _rangesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splitControllerProvider);
    final ctrl = ref.read(splitControllerProvider.notifier);
    final pageCountAsync = state.files.isEmpty
        ? null
        : ref.watch(pdfPageCountProvider(state.files.first.path));

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
              key: const ValueKey('split_ranges_field'),
              controller: _rangesCtrl,
              decoration: const InputDecoration(
                labelText: 'Ranges',
                hintText: '1-1, 2-end',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(splitRangesProvider.notifier).state = v,
            ),
            const SizedBox(height: 12),
            pageCountAsync?.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Could not read page count: $e'),
                  data: (count) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count pages',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      PdfThumbnailGrid(pageCount: count),
                    ],
                  ),
                ) ??
                const SizedBox.shrink(),
          ],
          const SizedBox(height: 12),
          if (state.isProcessing)
            ToolProgress(label: state.message ?? 'Splitting…'),
          if (state.hasError)
            ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult) ...[
            ToolSuccess(
              message:
                  'Split into ${state.resultFiles.length} verified file(s)',
              onShare: ctrl.shareResult,
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < state.resultFiles.length; i++)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.picture_as_pdf_outlined),
                      title: Text(
                        state.resultFiles[i].path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new_rounded),
                        tooltip: 'Open PDF',
                        onPressed: () =>
                            openDoc(context, state.resultFiles[i].path),
                      ),
                      onTap: () => openDoc(context, state.resultFiles[i].path),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.files.isEmpty || state.isProcessing
                ? null
                : () => runWithRename(
                    context: context,
                    ctrl: ctrl,
                    defaultName: defaultOutputName('Split'),
                  ),
            icon: const Icon(Icons.content_cut),
            label: const Text('Split'),
          ),
        ],
      ),
    );
  }
}
