import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/router/route_names.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/feedback/app_error_view.dart';
import '../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../data/files/datasources/files_local_data_source.dart';
import '../../../data/files/repositories/files_repository_impl.dart';
import '../bloc/mutation/files_mutation_bloc.dart';
import '../bloc/mutation/files_mutation_event.dart';
import '../bloc/mutation/files_mutation_state.dart';
import '../bloc/query/files_query_bloc.dart';
import '../bloc/query/files_query_event.dart';
import '../bloc/query/files_query_state.dart';
import '../../../features/tools/widgets/send_to_tool.dart';

/// FilesPage — strict Repository -> QueryBloc/MutationBloc -> UI per universal arch.
/// UI never imports Repository directly except via BlocProvider setup in router.
/// QueryBloc handles fetch/refresh, MutationBloc handles delete.
class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  Future<void> _confirmDelete(BuildContext context, String fileName, String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Delete file?'),
        content: Text('“$fileName” will be permanently deleted.', maxLines: 3, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<FilesMutationBloc>().add(FilesMutationEvent.deleteFile(filePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FilesMutationBloc, FilesMutationState>(
      listener: (context, state) {
        if (state.status == FilesMutationStatus.success) {
          context.read<FilesQueryBloc>().add(const FilesQueryEvent.refresh());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
        } else if (state.status == FilesMutationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Failed')));
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Files'),
              actions: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: () => context.read<FilesQueryBloc>().add(const FilesQueryEvent.refresh()),
                  tooltip: 'Refresh',
                ),
                const SizedBox(width: 8),
              ],
            ),
            BlocBuilder<FilesQueryBloc, FilesQueryState>(
              builder: (context, state) {
                if (state.status == FilesQueryStatus.loading || state.status == FilesQueryStatus.initial) {
                  return const SliverFillRemaining(child: AppLoadingIndicator());
                } else if (state.status == FilesQueryStatus.error) {
                  return SliverFillRemaining(
                    child: AppErrorView(
                      message: state.errorMessage ?? 'Something went wrong',
                      onRetry: () => context.read<FilesQueryBloc>().add(const FilesQueryEvent.fetch()),
                    ),
                  );
                } else if (state.status == FilesQueryStatus.loaded) {
                  final files = state.files;
                  if (files.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
                              child: Icon(Icons.folder_open_rounded, size: 40, color: Theme.of(context).colorScheme.onSecondaryContainer),
                            ),
                            const SizedBox(height: 16),
                            Text('No PDFs yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Your merged, compressed, scanned and converted PDFs will appear here.',
                                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            AppButton(label: 'Refresh', isOutlined: true, onPressed: () => context.read<FilesQueryBloc>().add(const FilesQueryEvent.refresh())),
                          ]),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    sliver: SliverList.separated(
                      itemCount: files.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final f = files[i];
                        final kb = (f.size / 1024).toStringAsFixed(1);
                        final date = f.modified.toLocal().toString().split('.').first;
                        return RepaintBoundary(
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.picture_as_pdf_rounded, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
                              ),
                              title: Text(f.name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: Text('$kb KB • $date', style: Theme.of(context).textTheme.bodySmall),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                BlocBuilder<FilesMutationBloc, FilesMutationState>(
                                  builder: (context, mState) {
                                    final isDeleting = mState.status == FilesMutationStatus.inProgress;
                                    return IconButton.filledTonal(
                                      icon: Icon(Icons.delete_outline_rounded, size: 16, color: isDeleting ? Colors.grey : null),
                                      onPressed: isDeleting ? null : () => _confirmDelete(context, f.name, f.path),
                                      tooltip: 'Delete',
                                      style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.send_rounded, size: 16),
                                  onPressed: () => SendToToolSheet.show(context, File(f.path)),
                                  tooltip: 'Send to tool',
                                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.share_rounded, size: 18),
                                  onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(f.path)])),
                                  style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(36, 36)),
                                ),
                              ]),
                              onTap: () => OpenFilex.open(f.path),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to provide Repository + Blocs at route level per universal arch.
/// Call this from app_router's builder for /files.
class FilesRouteProviders extends StatelessWidget {
  final Widget child;
  const FilesRouteProviders({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => FilesRepositoryImpl(FilesLocalDataSourceImpl()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => FilesQueryBloc(c.read<FilesRepositoryImpl>())..add(const FilesQueryEvent.fetch())),
          BlocProvider(create: (c) => FilesMutationBloc(c.read<FilesRepositoryImpl>())),
        ],
        child: child,
      ),
    );
  }
}
