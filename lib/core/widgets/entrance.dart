import 'package:flutter/material.dart';

/// Entrance animation for content that appears in response to an action
/// (result cards, error cards): fades in while settling upward.
/// Implicit (no controllers/tickers), 300ms ease-out — mirrors the route
/// transition easing so openings feel consistent across the app.
class EntranceFadeSlide extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: RepaintBoundary(child: child),
    );
  }
}
