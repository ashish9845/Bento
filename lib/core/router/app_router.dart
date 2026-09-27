import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/files/datasources/files_local_data_source.dart';
import '../../data/files/repositories/files_repository_impl.dart';
import '../../data/tools/datasources/pdf_engine_data_source.dart';
import '../../data/tools/repositories/tools_repository_impl.dart';
import '../../presentation/files/bloc/mutation/files_mutation_bloc.dart';
import '../../presentation/files/bloc/query/files_query_bloc.dart';
import '../../presentation/files/bloc/query/files_query_event.dart';
import '../../presentation/files/pages/files_page.dart';
import '../../presentation/home/bloc/mutation/home_mutation_bloc.dart';
import '../../presentation/home/pages/home_page.dart';
import '../../presentation/tools/image2pdf/bloc/mutation/image2pdf_mutation_bloc.dart';
import '../../presentation/tools/image2pdf/pages/image2pdf_page.dart';
import '../../presentation/tools/merge/bloc/mutation/merge_mutation_bloc.dart';
import '../../presentation/tools/merge/pages/merge_page.dart';
import '../../features/scan/openscan/openscan_capture_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tools/compress/compress_screen.dart';
import '../../features/tools/extract/extract_screen.dart';
import '../../features/tools/home/tool_grid_screen.dart';
import '../../features/tools/organize/organize_screen.dart';
import '../../features/tools/pdf2image/pdf2image_screen.dart';
import '../../features/tools/protect/protect_screen.dart';
import '../../features/tools/sign/sign_screen.dart';
import '../../features/tools/unlock/unlock_screen.dart';
import '../../features/tools/split/split_screen.dart';
import '../routing/app_shell.dart';

import 'package:scan/core/routing/route_transitions.dart';

import 'route_names.dart';
import 'route_paths.dart';

/// Strict universal arch router — go_router single table, named routes, Bloc per route.
/// See flutter_architecture_universal.md Routing Rules.
final appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RouteNames.home,
              path: RoutePaths.home,
              builder: (context, state) => RepositoryProvider(
                create: (_) => FilesRepositoryImpl(FilesLocalDataSourceImpl()),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (c) =>
                          FilesQueryBloc(c.read<FilesRepositoryImpl>())
                            ..add(const FilesQueryEvent.fetch()),
                    ),
                    BlocProvider(
                      create: (c) =>
                          HomeMutationBloc(c.read<FilesRepositoryImpl>()),
                    ),
                  ],
                  child: const HomePage(),
                ),
              ),
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
                    BlocProvider(
                      create: (c) =>
                          FilesQueryBloc(c.read<FilesRepositoryImpl>())
                            ..add(const FilesQueryEvent.fetch()),
                    ),
                    BlocProvider(
                      create: (c) =>
                          FilesMutationBloc(c.read<FilesRepositoryImpl>()),
                    ),
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
              name: RouteNames.tools,
              path: RoutePaths.tools,
              builder: (context, state) => const ToolGridScreen(),
              routes: [
                GoRoute(
                  name: RouteNames.toolsMerge,
                  path: 'merge',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: RepositoryProvider(
                      create: (_) =>
                          ToolsRepositoryImpl(PdfEngineDataSourceImpl()),
                      child: BlocProvider(
                        create: (c) =>
                            MergeMutationBloc(c.read<ToolsRepositoryImpl>()),
                        child: const MergePage(),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsSplit,
                  path: 'split',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const SplitScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsOrganize,
                  path: 'organize',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const OrganizeScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsExtract,
                  path: 'extract',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const ExtractScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsCompress,
                  path: 'compress',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const CompressScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsImage2Pdf,
                  path: 'image2pdf',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: RepositoryProvider(
                      create: (_) =>
                          ToolsRepositoryImpl(PdfEngineDataSourceImpl()),
                      child: BlocProvider(
                        create: (c) => Image2PdfMutationBloc(
                          c.read<ToolsRepositoryImpl>(),
                        ),
                        child: const Image2PdfPage(),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsPdf2Image,
                  path: 'pdf2image',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const Pdf2ImageScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsProtect,
                  path: 'protect',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const ProtectScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsUnlock,
                  path: 'unlock',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const UnlockScreen(),
                  ),
                ),
                GoRoute(
                  name: RouteNames.toolsSign,
                  path: 'sign',
                  pageBuilder: (context, state) => buildAppTransitionPage(
                    key: state.pageKey,
                    child: const SignScreen(),
                  ),
                ),
              ],
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
    // Full-screen scanner (no bottom bar) — opened from Home shortcut/FAB.
    GoRoute(
      name: RouteNames.scan,
      path: RoutePaths.scan,
      pageBuilder: (context, state) => buildAppTransitionPage(
        key: state.pageKey,
        style: ScreenTransitionStyle.slideUp,
        child: const ScanScreen(),
      ),
      routes: [
        // iOS-only OpenScan capture flow.
        GoRoute(
          name: RouteNames.openscan,
          path: 'openscan',
          pageBuilder: (context, state) => buildAppTransitionPage(
            key: state.pageKey,
            child: const OpenScanCaptureScreen(),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text(state.error.toString()))),
);
