// Screen-transition system inspired by mpvRx's animation framework
// (ControlsAnimationStyle / NavigationAnimStyle): a small set of named
// styles with expressive easing, one shared builder so every screen opens
// the same way. System reduced-motion is always respected.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Which open animation a pushed screen uses.
enum ScreenTransitionStyle {
  /// M3 fade-through with a subtle settle (default for tool screens).
  fadeThrough,

  /// Rises like a sheet (full-screen flows such as Scan).
  slideUp,

  /// Gentle zoom from 96% (spotlight moments).
  zoom,

  /// No animation (also forced when the OS requests reduced motion).
  none,
}

/// Builds a [CustomTransitionPage] with the shared [style] — use for every
/// pushed sub-route so openings feel consistent across the app.
CustomTransitionPage<void> buildAppTransitionPage({
  required LocalKey key,
  required Widget child,
  ScreenTransitionStyle style = ScreenTransitionStyle.fadeThrough,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (style == ScreenTransitionStyle.none ||
          MediaQuery.disableAnimationsOf(context)) {
        return child;
      }
      return _StyledTransition(
        style: style,
        animation: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
  );
}

class _StyledTransition extends StatelessWidget {
  const new({
    required this.style,
    required this.animation,
    required this.child,
  });

  final ScreenTransitionStyle style;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    switch (style) {
      case ScreenTransitionStyle.slideUp:
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      case ScreenTransitionStyle.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      case ScreenTransitionStyle.none:
        return child;
      case ScreenTransitionStyle.fadeThrough:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
    }
  }
}
