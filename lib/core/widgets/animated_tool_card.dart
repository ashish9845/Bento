import 'package:flutter/material.dart';

/// Launcher-style tool cell — a rounded icon tile with the name underneath,
/// like a phone home screen. No card chrome, no badges.
/// Per SKILL.md: implicit animations, RepaintBoundary, no per-card Ticker.
class AnimatedToolCard extends StatelessWidget {
  const new({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
    this.delayMs = 0,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Use TweenAnimationBuilder instead of AnimationController per card to reduce tickers (10 -> 0)
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Tile scales with the cell: compact on phones, roomier on tablets.
                  final tile = (constraints.maxWidth * 0.68).clamp(46.0, 84.0);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: tile,
                        height: tile,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(tile * 0.28),
                        ),
                        child: Icon(
                          icon,
                          size: tile * 0.46,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: scheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
