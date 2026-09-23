import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scan/core/widgets/animated_tool_card.dart';

class _Tool {
  const _Tool(this.label, this.icon, this.route, this.subtitle, this.isEngine);
  final String label;
  final IconData icon;
  final String route;
  final String subtitle;
  final bool isEngine;
}

const _tools = [
  _Tool('Merge PDFs', Icons.merge_rounded, '/tools/merge', 'Combine multiple PDFs', true),
  _Tool('Split PDF', Icons.content_cut_rounded, '/tools/split', 'Split by ranges', true),
  _Tool('Organize Pages', Icons.view_carousel_rounded, '/tools/organize', 'Rotate / delete / reorder', true),
  _Tool('Extract Pages', Icons.filter_none_rounded, '/tools/extract', 'Extract selected pages', true),
  _Tool('Compress PDF', Icons.compress_rounded, '/tools/compress', 'Reduce file size', true),
  _Tool('Image → PDF', Icons.image_rounded, '/tools/image2pdf', 'Images to PDF', true),
  _Tool('PDF → Image', Icons.image_search_rounded, '/tools/pdf2image', 'Export pages as images', true),
  _Tool('Sign PDF', Icons.draw_rounded, '/tools/sign', 'Add signature (native)', false),
];

class ToolGridScreen extends StatelessWidget {
  const ToolGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 148,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.85),
                      Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.lunch_dining_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Bento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1)),
                            Text('Offline PDF toolkit', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ]),
                          const Spacer(),
                          Semantics(
                            label: 'About Bento',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.info_outline_rounded),
                              onPressed: () => context.go('/settings'),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        // search placeholder
                        Container(
                          height: 42,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6))),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(children: [
                            Icon(Icons.search_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Text('Search tools…', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const Spacer(),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)), child: Text('8 tools', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700))),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final cross = width > 700 ? 3 : 2;
                final aspect = width > 700 ? 1.1 : 1.02;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: aspect,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tool = _tools[index];
                      return RepaintBoundary(
                        child: AnimatedToolCard(
                          label: tool.label,
                          subtitle: tool.subtitle,
                          icon: tool.icon,
                          isEngine: tool.isEngine,
                          delayMs: index * 55,
                          onTap: () => context.go(tool.route),
                        ),
                      );
                    },
                    childCount: _tools.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
