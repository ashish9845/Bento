import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/files/datasources/files_local_data_source.dart';
import '../../data/files/repositories/files_repository_impl.dart';
import '../../data/tools/datasources/tools_local_data_source.dart';
import '../../data/tools/repositories/tools_repository_impl.dart';
import '../../presentation/files/bloc/mutation/files_mutation_bloc.dart';
import '../../presentation/files/bloc/query/files_query_bloc.dart';
import '../../presentation/files/bloc/query/files_query_event.dart';
import '../../presentation/files/pages/files_page.dart';
import '../../presentation/tools/image2pdf/bloc/mutation/image2pdf_mutation_bloc.dart';
import '../../presentation/tools/image2pdf/pages/image2pdf_page.dart';
import '../../presentation/tools/merge/bloc/mutation/merge_mutation_bloc.dart';
import '../../presentation/tools/merge/pages/merge_page.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tools/compress/compress_screen.dart';
import '../../features/tools/extract/extract_screen.dart';
import '../../features/tools/home/tool_grid_screen.dart';
import '../../features/tools/organize/organize_screen.dart';
import '../../features/tools/pdf2image/pdf2image_screen.dart';
import '../../features/tools/sign/sign_screen.dart';
import '../../features/tools/split/split_screen.dart';
import '../routing/app_shell.dart';
import 'route_names.dart';
import 'route_paths.dart';

/// Strict universal arch router — go_router single table, named routes, Bloc per route.
/// See flutter_architecture_universal.md Routing Rules.
final appRouter = GoRouter(
  initialLocation: RoutePaths.tools,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteNames.tools,
              path: RoutePaths.tools,
              builder: (context, state) => const ToolGridScreen(),
              routes: [
                GoRoute(
                  name: RouteNames.toolsMerge,
                  path: 'merge',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: RepositoryProvider(
                      create: (_) => ToolsRepositoryImpl(ToolsLocalDataSourceImpl()),
                      child: BlocProvider(
                        create: (c) => MergeMutationBloc(c.read<ToolsRepositoryImpl>()),
                        child: const MergePage(),
                      ),
                    ),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child)),
                    transitionDuration: const Duration(milliseconds: 280),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsSplit,
                  path: 'split',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SplitScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsOrganize,
                  path: 'organize',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const OrganizeScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsExtract,
                  path: 'extract',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const ExtractScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsCompress,
                  path: 'compress',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const CompressScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child)),
                    transitionDuration: const Duration(milliseconds: 280),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsImage2Pdf,
                  path: 'image2pdf',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: RepositoryProvider(
                      create: (_) => ToolsRepositoryImpl(ToolsLocalDataSourceImpl()),
                      child: BlocProvider(
                        create: (c) => Image2PdfMutationBloc(c.read<ToolsRepositoryImpl>()),
                        child: const Image2PdfPage(),
                      ),
                    ),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsPdf2Image,
                  path: 'pdf2image',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const Pdf2ImageScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsSign,
                  path: 'sign',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SignScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child)),
                    transitionDuration: const Duration(milliseconds: 260),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteNames.scan,
              path: RoutePaths.scan,
              builder: (context, state) => const ScanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteNames.files,
              path: RoutePaths.files,
              builder: (context, state) => RepositoryProvider(
                create: (_) => FilesRepositoryImpl(FilesLocalDataSourceImpl()),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (c) => FilesQueryBloc(c.read<FilesRepositoryImpl>())..add(const FilesQueryEvent.fetch())),
                    BlocProvider(create: (c) => FilesMutationBloc(c.read<FilesRepositoryImpl>())),
                  ],
                  child: const FilesPage(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteNames.settings,
              path: RoutePaths.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
);
