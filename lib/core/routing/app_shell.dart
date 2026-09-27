import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../router/route_names.dart';

/// Bottom-nav shell: swipeable tabs with animated branch transitions.
///
/// Swipe left/right switches branches (clamped at the ends). Branch
/// switches — by swipe or tap — cross-slide with a fade. Inner horizontal
/// scrollers (carousels, reorder grids, drawing canvases) win the gesture
/// arena, so their drags never switch tabs.
class AppShell extends StatefulWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int? _prevIndex;
  int _direction = 1;

  void _goBranch(int index) {
    final shell = widget.navigationShell;
    if (index == shell.currentIndex) return;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  void _onHorizontalFling(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    const threshold = 450;
    final shell = widget.navigationShell;
    if (velocity < -threshold && shell.currentIndex < 3) {
      _goBranch(shell.currentIndex + 1);
    } else if (velocity > threshold && shell.currentIndex > 0) {
      _goBranch(shell.currentIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final scheme = Theme.of(context).colorScheme;
    final isHome = shell.currentIndex == 0;
    // Direction for the slide: derived from index movement so taps,
    // deep links and swipes all animate the right way.
    if (_prevIndex != null && _prevIndex != shell.currentIndex) {
      _direction = shell.currentIndex > _prevIndex! ? 1 : -1;
    }
    _prevIndex = shell.currentIndex;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: _onHorizontalFling,
        // Single-child entrance animator (not AnimatedSwitcher: the shell
        // carries a GlobalKey and must never exist twice in the tree).
        child: _BranchTransition(
          index: shell.currentIndex,
          direction: _direction,
          child: shell,
        ),
      ),
      floatingActionButton: isHome
          ? FloatingActionButton(
              key: const ValueKey('home_scan_fab'),
              tooltip: 'Scan document',
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onPressed: () => GoRouter.of(context).pushNamed(RouteNames.scan),
              child: const Icon(Symbols.document_scanner),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        animationDuration: const Duration(milliseconds: 320),
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
        indicatorColor: scheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.home_app_logo),
            selectedIcon: Icon(Symbols.home_app_logo),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Symbols.files),
            selectedIcon: Icon(Symbols.files),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Symbols.browse),
            selectedIcon: Icon(Symbols.browse),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Me',
          ),
        ],
      ),
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
