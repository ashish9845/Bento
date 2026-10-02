// dart:io here is view-only (Image.file thumbnails). No data access;
// picking + PDF work live in the Bloc.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/open_file.dart';

import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/dialogs/name_prompt_dialog.dart';
import '../../../shared/widgets/feedback/app_error_view.dart';
import '../bloc/mutation/image2pdf_mutation_bloc.dart';
import '../bloc/mutation/image2pdf_mutation_event.dart';
import '../bloc/mutation/image2pdf_mutation_state.dart';

/// Image2PdfPage — strict REPO/DATA <-> BLOC <-> UI.
/// UI never imports Repository, DataSource, ImagePicker, SharedPreferences,
/// path_provider, or SharePlus. Picking/reorder/remove/clear all live in
/// [Image2PdfMutationBloc] via an injectable picker gateway; UI only
/// dispatches events, renders via BlocBuilder/Listener, shows the rename
/// dialog shell, and navigates. `dart:io` above is view-only (Image.file
/// thumbnails). `openDoc` is a context-bound UI helper, not a data import.
class Image2PdfPage extends StatelessWidget {
  const new({super.key});

  /// Pure view shell: collects the output name, then dispatches submit.
  /// [paths] comes from Bloc state — never from local UI data.
  Future<void> _createWithRename(
    BuildContext context,
    List<String> paths,
  ) async {
    if (paths.isEmpty) return;
    final now = DateTime.now();
    final defaultName =
        'Bento_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final name = await showNamePrompt(
      context,
      title: 'Name your PDF',
      defaultName: defaultName,
      confirmLabel: 'Create',
    );
    if (name == null || name.isEmpty) return;
    if (!context.mounted) return;
    context.read<Image2PdfMutationBloc>().add(
      Image2PdfMutationEvent.submit(paths, outputName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image → PDF')),
      body: BlocListener<Image2PdfMutationBloc, Image2PdfMutationState>(
        listener: (context, state) {
          if (state.status == Image2PdfMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'PDF created: ${state.resultPath?.split('/').last ?? ''}',
                ),
              ),
            );
          } else if (state.status == Image2PdfMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: BlocBuilder<Image2PdfMutationBloc, Image2PdfMutationState>(
              builder: (context, selection) {
                final paths = selection.pickedPaths;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.image_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              paths.isEmpty
                                  ? 'No images'
                                  : '${paths.length} image${paths.length == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (paths.isEmpty) ...[
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Pick images',
                                isOutlined: true,
                                onPressed: () =>
                                    context.read<Image2PdfMutationBloc>().add(
                                      const Image2PdfMutationEvent.pickRequested(),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (paths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Long-press and drag to reorder',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.read<Image2PdfMutationBloc>().add(
                                  const Image2PdfMutationEvent.clearSelection(),
                                ),
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Clear all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: paths.length,
                        itemBuilder: (context, index) {
                          final path = paths[index];
                          final tile = _ImageTile(
                            position: index + 1,
                            path: path,
                            onRemove: () => context
                                .read<Image2PdfMutationBloc>()
                                .add(Image2PdfMutationEvent.removeAt(index)),
                          );
                          return DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              final from = paths.indexOf(details.data);
                              final to = paths.indexOf(path);
                              if (from >= 0 && to >= 0 && from != to) {
                                context.read<Image2PdfMutationBloc>().add(
                                  Image2PdfMutationEvent.reordered(from, to),
                                );
                              }
                            },
                            builder: (context, candidate, rejected) =>
                                Container(
                                  decoration: candidate.isNotEmpty
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        )
                                      : null,
                                  child: LongPressDraggable<String>(
                                    data: path,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: 100,
                                        height: 135,
                                        child: tile,
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: tile,
                                    ),
                                    child: tile,
                                  ),
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Add more images',
                        isOutlined: true,
                        icon: Icons.add_photo_alternate_outlined,
                        onPressed: () => context
                            .read<Image2PdfMutationBloc>()
                            .add(const Image2PdfMutationEvent.pickRequested()),
                      ),
                    ],
                    const SizedBox(height: 16),
                    BlocBuilder<Image2PdfMutationBloc, Image2PdfMutationState>(
                      builder: (context, state) {
                        final isLoading =
                            state.status == Image2PdfMutationStatus.inProgress;
                        if (state.status == Image2PdfMutationStatus.failure) {
                          return AppErrorView(
                            message: state.errorMessage ?? 'Failed',
                            onRetry: () => _createWithRename(context, paths),
                          );
                        }
                        if (state.status == Image2PdfMutationStatus.success &&
                            state.resultPath != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
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
                                      onPressed: () =>
                                          openDoc(context, state.resultPath!),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppButton(
                                      label: 'Create another',
                                      isOutlined: true,
                                      onPressed: () => context
                                          .read<Image2PdfMutationBloc>()
                                          .add(
                                            const Image2PdfMutationEvent.clearSelection(),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return AppButton(
                          label: 'Create PDF',
                          isLoading: isLoading,
                          onPressed: paths.isEmpty || isLoading
                              ? null
                              : () => _createWithRename(context, paths),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const new({
    required this.position,
    required this.path,
    required this.onRemove,
  });

  final int position;
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(path), fit: BoxFit.cover),
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
