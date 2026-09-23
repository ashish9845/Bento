import 'package:flutter/material.dart';

/// Polished scaffold per SKILL.md — responsive, animated, hero, warm theme.
class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.actions,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            expandedHeight: subtitle == null ? 110 : 148,
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16, end: 60),
              title: Hero(
                tag: 'tool_$title',
                child: Material(
                  color: Colors.transparent,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35)],
                  ),
                ),
              ),
            ),
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
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        const SizedBox(width: 10),
                        Expanded(child: Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35))),
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
                  builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
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
        const Icon(Icons.auto_awesome_rounded, size: 44, color: Colors.brown),
        const SizedBox(height: 12),
        Text('$toolName — ready', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Pick files → tune options → run. Engine uses local file URLs (not base64) for large PDFs.',
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
