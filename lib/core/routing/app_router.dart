import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scan/core/routing/app_shell.dart';
import 'package:scan/features/files/files_screen.dart';
import 'package:scan/features/scan/scan_screen.dart';
import 'package:scan/features/settings/settings_screen.dart';
import 'package:scan/features/tools/compress/compress_screen.dart';
import 'package:scan/features/tools/extract/extract_screen.dart';
import 'package:scan/features/tools/home/tool_grid_screen.dart';
import 'package:scan/features/tools/image2pdf/image2pdf_screen.dart';
import 'package:scan/features/tools/merge/merge_screen.dart';
import 'package:scan/features/tools/organize/organize_screen.dart';
import 'package:scan/features/tools/pdf2image/pdf2image_screen.dart';
import 'package:scan/features/tools/sign/sign_screen.dart';
import 'package:scan/features/tools/split/split_screen.dart';

/// go_router config — confirmed in TODO.md Phase 0.
final appRouter = GoRouter(
  initialLocation: '/tools',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tools',
              builder: (context, state) => const ToolGridScreen(),
              routes: [
                GoRoute(
                  path: 'merge',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const MergeScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child)),
                    transitionDuration: const Duration(milliseconds: 280),
                  ),
                ),
                GoRoute(
                  path: 'split',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SplitScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  path: 'organize',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const OrganizeScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  path: 'extract',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const ExtractScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  path: 'compress',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const CompressScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child)),
                    transitionDuration: const Duration(milliseconds: 280),
                  ),
                ),
                GoRoute(
                  path: 'image2pdf',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const Image2PdfScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
                  path: 'pdf2image',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const Pdf2ImageScreen(),
                    transitionsBuilder: (context, a, sa, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 220),
                  ),
                ),
                GoRoute(
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
              path: '/scan',
              builder: (context, state) => const ScanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text(state.error.toString())),
  ),
);
