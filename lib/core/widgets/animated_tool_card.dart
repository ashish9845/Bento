import 'package:flutter/material.dart';

/// Optimized tool card — no per-card Ticker, uses TweenAnimationBuilder for 60fps.
/// Per SKILL.md: implicit animations, RepaintBoundary, avoid expensive controllers.
class AnimatedToolCard extends StatelessWidget {
  const AnimatedToolCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isEngine,
    required this.onTap,
    super.key,
    this.delayMs = 0,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool isEngine;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Use TweenAnimationBuilder instead of AnimationController per card to reduce tickers (8 -> 0)
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - v)),
          child: child,
        ),
      ),
      child: RepaintBoundary(
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
                  ),
                  const Spacer(),
                  Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEngine ? scheme.secondaryContainer : scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(isEngine ? Icons.bolt_rounded : Icons.draw_rounded, size: 12, color: isEngine ? scheme.onSecondaryContainer : scheme.onTertiaryContainer),
                      const SizedBox(width: 4),
                      Text(isEngine ? 'Engine' : 'Native', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 11, color: isEngine ? scheme.onSecondaryContainer : scheme.onTertiaryContainer)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
