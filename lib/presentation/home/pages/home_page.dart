import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/open_file.dart';
import '../../shared/widgets/feedback/app_error_view.dart';
import '../../shared/widgets/feedback/app_loading_indicator.dart';
import '../bloc/mutation/home_mutation_bloc.dart';
import '../bloc/mutation/home_mutation_state.dart';
import '../../files/bloc/query/files_query_bloc.dart';
import '../../files/bloc/query/files_query_event.dart';
import '../../files/bloc/query/files_query_state.dart';
import '../widgets/home_recents.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_shortcut_grid.dart';

/// Home dashboard — search, shortcut grid, recents feed.
/// Strict Repository → Bloc → UI: recents come from [FilesQueryBloc];
/// import outcomes arrive via [HomeMutationBloc]; both provided at the route level.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HomeShortcut> _shortcuts() => const [
        HomeShortcut(
          id: 'scan',
          label: 'Smart Scan',
          icon: Symbols.document_scanner,
          routeName: RouteNames.scan,
          keywords: ['scan', 'camera', 'document', 'smart', 'capture'],
        ),
        HomeShortcut(
          id: 'tools',
          label: 'PDF Tools',
          icon: Icons.grid_view_rounded,
          routeName: RouteNames.tools,
          keywords: ['tools', 'pdf', 'all', 'toolbox'],
        ),
        HomeShortcut(
          id: 'sign',
          label: 'Sign PDF',
          icon: Symbols.stylus_note,
          routeName: RouteNames.toolsSign,
          keywords: ['sign', 'signature', 'draw', 'approve'],
        ),
        HomeShortcut(
          id: 'compress',
          label: 'Compress',
          icon: Icons.compress_rounded,
          routeName: RouteNames.toolsCompress,
          keywords: ['compress', 'shrink', 'reduce', 'size', 'smaller', 'optimize'],
        ),
        HomeShortcut(
          id: 'merge',
          label: 'Merge PDFs',
          icon: Icons.merge_rounded,
          routeName: RouteNames.toolsMerge,
          keywords: ['merge', 'combine', 'join', 'append', 'join', 'bind'],
        ),
        HomeShortcut(
          id: 'protect',
          label: 'Protect PDF',
          icon: Symbols.add_moderator,
          routeName: RouteNames.toolsProtect,
          keywords: ['protect', 'password', 'encrypt', 'lock', 'secure', 'aes'],
        ),
        HomeShortcut(
          id: 'unlock',
          label: 'Unlock PDF',
          icon: Symbols.encrypted_off,
          routeName: RouteNames.toolsUnlock,
          keywords: ['unlock', 'decrypt', 'remove password', 'open locked'],
        ),
        HomeShortcut(
          id: 'all',
          label: 'All',
          icon: Icons.apps_rounded,
          routeName: RouteNames.tools,
          keywords: ['all', 'list', 'browse', 'more'],
        ),
      ];

  void _onShortcut(HomeShortcut shortcut) {
    final name = shortcut.routeName;
    if (name == null) return;
    if (name == RouteNames.tools || name == RouteNames.files) {
      // Tab destinations: switch branches.
      context.goNamed(name);
    } else {
      // Tool/scanner pages: push over Home so there is no Tools-grid flash
      // and back returns straight here.
      context.pushNamed(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allShortcuts = _shortcuts();
    final q = _query.trim().toLowerCase();
    final visibleShortcuts = allShortcuts.where((s) => s.matches(q)).toList();

    return BlocListener<HomeMutationBloc, HomeMutationState>(
      listener: (context, state) {
        if (state.status == HomeMutationStatus.success) {
          context.read<FilesQueryBloc>().add(const FilesQueryEvent.refresh());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${state.importedCount} file(s) to Recents'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () => context.goNamed(RouteNames.files),
              ),
            ),
          );
        } else if (state.status == HomeMutationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Import failed')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: scheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.lunch_dining_rounded, color: scheme.onPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Bento',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ]),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  HomeSearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 16),
                  if (visibleShortcuts.isNotEmpty)
                    HomeShortcutGrid(shortcuts: visibleShortcuts, onSelect: _onShortcut)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No tools match "$_query"',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: Text('Recents',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.files),
                      child: const Text('View all'),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  BlocBuilder<FilesQueryBloc, FilesQueryState>(
                    builder: (context, state) {
                      if (state.status == FilesQueryStatus.loading ||
                          state.status == FilesQueryStatus.initial) {
                        return const SizedBox(
                          height: 120,
                          child: AppLoadingIndicator(),
                        );
                      }
                      if (state.status == FilesQueryStatus.error) {
                        return AppErrorView(
                          message: state.errorMessage ?? 'Something went wrong',
                          onRetry: () =>
                              context.read<FilesQueryBloc>().add(const FilesQueryEvent.fetch()),
                        );
                      }
                      final files = q.isEmpty
                          ? state.files.take(5).toList()
                          : state.files.where((f) => f.name.toLowerCase().contains(q)).take(5).toList();
                      return HomeRecents(
                        files: files,
                        onOpen: (f) => openDoc(context, f.path),
                      );
                    },
                  ),
                  BlocBuilder<HomeMutationBloc, HomeMutationState>(
                    builder: (context, mState) {
                      if (mState.status != HomeMutationStatus.inProgress) {
                        return const SizedBox.shrink();
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
