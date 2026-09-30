import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../router/route_names.dart';
import 'glass_nav_bar.dart';

/// Bottom-nav shell with animated branch transitions.
///
/// Tab switches cross-slide with a fade (direction-aware). There is no swipe
/// gesture — tabs change by tapping the navigation bar only.
///
/// The bar is a floating frosted-glass pill ([GlassNavBar]) shared by all
/// platforms; only the chrome hides on pushed sub-pages.
class AppShell extends StatefulWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int? _prevIndex;
  int _direction = 1;

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final scheme = Theme.of(context).colorScheme;
    final isHome = shell.currentIndex == 0;
    // Direction for the slide: derived from index movement so taps and
    // deep links animate the right way.
    if (_prevIndex != null && _prevIndex != shell.currentIndex) {
      _direction = shell.currentIndex > _prevIndex! ? 1 : -1;
    }
    _prevIndex = shell.currentIndex;
    // Bottom bar + FAB live only on the four tab roots. Pushed sub-pages
    // (tool screens, etc.) go fullscreen — navigation behavior is untouched,
    // only the chrome hides. Matched against branch roots so query params
    // or trailing slashes can't accidentally hide the bar on a tab.
    final topRoute = GoRouterState.of(context).topRoute;
    final isTabRoot =
        topRoute is GoRoute &&
        (topRoute.path == '/' ||
            topRoute.path == '/files' ||
            topRoute.path == '/tools' ||
            topRoute.path == '/settings');

    return Scaffold(
      // Single-child entrance animator (not AnimatedSwitcher: the shell
      // carries a GlobalKey and must never exist twice in the tree).
      body: _BranchTransition(
        index: shell.currentIndex,
        direction: _direction,
        child: shell,
      ),
      floatingActionButton: isHome && isTabRoot
          ? FloatingActionButton(
              key: const ValueKey('home_scan_fab'),
              tooltip: 'Scan document',
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onPressed: () => GoRouter.of(context).pushNamed(RouteNames.scan),
              child: const Icon(Symbols.document_scanner),
            )
          : null,
      bottomNavigationBar: isTabRoot
          ? GlassNavBar(
              currentIndex: shell.currentIndex,
              onTap: (i) => shell.goBranch(
                i,
                initialLocation: i == shell.currentIndex,
              ),
              items: const [
                GlassNavItem(
                  label: 'Home',
                  icon: Symbols.home_app_logo,
                ),
                GlassNavItem(label: 'Files', icon: Symbols.files),
                GlassNavItem(label: 'Tools', icon: Symbols.browse),
                GlassNavItem(
                  label: 'Me',
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person_rounded,
                ),
              ],
            )
          : null,
    );
  }
}

/// Plays a fade+slide entrance on the single shell child whenever the branch
/// [index] changes. A plain implicit wrapper (no duplicated subtree), so the
/// shell's GlobalKey is never mounted twice.
class _BranchTransition extends StatefulWidget {
  const new({
    required this.index,
    required this.direction,
    required this.child,
  });

  final int index;
  final int direction;
  final Widget child;

  @override
  State<_BranchTransition> createState() => _BranchTransitionState();
}

class _BranchTransitionState extends State<_BranchTransition>
    with SingleTickerProviderStateMixin {
  // Starts settled (value 1) so first build shows content instantly.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_BranchTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0.07 * widget.direction, 0),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
