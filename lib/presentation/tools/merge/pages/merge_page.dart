import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/open_file.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/dialogs/name_prompt_dialog.dart';
import '../../../shared/widgets/feedback/app_error_view.dart';
import '../bloc/mutation/merge_mutation_bloc.dart';
import '../bloc/mutation/merge_mutation_event.dart';
import '../bloc/mutation/merge_mutation_state.dart';

/// MergePage — strict REPO/DATA <-> BLOC <-> UI.
/// UI never imports Repository, DataSource, FilePicker, SharedPreferences,
/// path_provider, dart:io for data, or SharePlus. All async/data flows via
/// [MergeMutationBloc]: UI only dispatches events, renders via
/// BlocBuilder/Listener, shows the rename dialog shell, and navigates.
/// `openDoc` is a context-bound UI helper (snackbars), not a data import.
class MergePage extends StatelessWidget {
  const new({super.key});

  /// Pure view shell: collects the output name, then dispatches submit.
  /// [pickedPaths] comes from Bloc state — never from local UI data.
  Future<void> _mergeWithRename(
    BuildContext context,
    List<String> pickedPaths,
  ) async {
    if (pickedPaths.length < 2) return;
    final now = DateTime.now();
    final defaultName =
        'Merged_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final name = await showNamePrompt(
      context,
      title: 'Name your PDF',
      defaultName: defaultName,
      hintText: 'Merged',
      confirmLabel: 'Merge',
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    context.read<MergeMutationBloc>().add(
      MergeMutationEvent.submitMerge(pickedPaths, outputName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDFs')),
      body: BlocListener<MergeMutationBloc, MergeMutationState>(
        listener: (context, state) {
          if (state.status == MergeMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Merged: ${state.resultPath?.split('/').last ?? ''}',
                ),
              ),
            );
          } else if (state.status == MergeMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<MergeMutationBloc, MergeMutationState>(
            builder: (context, selection) {
              final pickedPaths = selection.pickedPaths;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 32,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pickedPaths.isEmpty
                                ? 'No files picked'
                                : '${pickedPaths.length} PDFs selected',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Pick PDFs',
                            isOutlined: true,
                            onPressed: () => context
                                .read<MergeMutationBloc>()
                                .add(
                                  const MergeMutationEvent.pickRequested(),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (pickedPaths.length >= 2) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order — drag to rearrange',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context
                              .read<MergeMutationBloc>()
                              .add(
                                const MergeMutationEvent.clearSelection(),
                              ),
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Clear all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RepaintBoundary(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pickedPaths.length,
                            onReorderItem: (oldIndex, newIndex) => context
                                .read<MergeMutationBloc>()
                                .add(
                                  MergeMutationEvent.reordered(
                                    oldIndex,
                                    newIndex,
                                  ),
                                ),
                            itemBuilder: (context, i) => ListTile(
                              key: ValueKey(pickedPaths[i]),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              title: Text(
                                pickedPaths[i].split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    tooltip: 'Remove',
                                    onPressed: () => context
                                        .read<MergeMutationBloc>()
                                        .add(
                                          MergeMutationEvent.removeAt(i),
                                        ),
                                  ),
                                  const Icon(Icons.drag_handle_rounded),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  BlocBuilder<MergeMutationBloc, MergeMutationState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == MergeMutationStatus.inProgress;
                      if (state.status == MergeMutationStatus.failure) {
                        return AppErrorView(
                          message: state.errorMessage ?? 'Failed',
                          onRetry: () =>
                              _mergeWithRename(context, pickedPaths),
                        );
                      }
                      if (state.status == MergeMutationStatus.success &&
                          state.resultPath != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Saved: ${state.resultPath!.split('/').last}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: 'Open PDF',
                                    icon: Icons.open_in_new_rounded,
                                    onPressed: () => openDoc(
                                      context,
                                      state.resultPath!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppButton(
                                    label: 'Merge more',
                                    isOutlined: true,
                                    onPressed: () => context
                                        .read<MergeMutationBloc>()
                                        .add(
                                          const MergeMutationEvent.clearSelection(),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return AppButton(
                        label: 'Merge',
                        isLoading: isLoading,
                        onPressed: pickedPaths.length < 2 || isLoading
                            ? null
                            : () => _mergeWithRename(context, pickedPaths),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
