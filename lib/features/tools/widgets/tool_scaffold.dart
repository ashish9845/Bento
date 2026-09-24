import 'package:flutter/material.dart';

/// Shared scaffold for per-tool screens — same compact pinned header everywhere
/// (matches the tab headers), so every tool looks identical up top.
class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.actions,
    this.icon,
    this.physics,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final IconData? icon;

  /// Allows screens with their own drag gestures (e.g. the Sign pad) to lock
  /// page scrolling while a stroke is in progress.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: physics ?? const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: actions,
            title: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 700 ? 24 : 16,
              vertical: 16,
            ),
            sliver: SliverList.list(
              children: [
                if (subtitle != null) ...[
                  RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: scheme.onSecondaryContainer),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(subtitle!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // staggered entrance
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                          offset: Offset(0, 12 * (1 - v)), child: child)),
                  child: RepaintBoundary(child: child),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ToolPlaceholder extends StatelessWidget {
  const ToolPlaceholder({required this.toolName, super.key});
  final String toolName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text('$toolName — ready',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Pick files → tune options → run. Processing runs on-device in the native engine.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 24),
        const ToolEmptyState(),
      ],
    );
  }
}

class ToolEmptyState extends StatelessWidget {
  const ToolEmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.folder_open_rounded, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 14),
          Text('No file selected', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Tap Pick file to begin — 60fps, off-main-thread PDF work', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
