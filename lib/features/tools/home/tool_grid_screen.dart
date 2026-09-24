import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scan/core/router/route_names.dart';
import 'package:scan/core/widgets/animated_tool_card.dart';

class _Tool {
  const _Tool(this.label, this.icon, this.routeName, this.subtitle, this.isEngine);
  final String label;
  final IconData icon;
  final String routeName;
  final String subtitle;
  final bool isEngine;
}

const _tools = [
  _Tool('Merge PDFs', Icons.merge_rounded, RouteNames.toolsMerge, 'Combine multiple PDFs', true),
  _Tool('Split PDF', Icons.content_cut_rounded, RouteNames.toolsSplit, 'Split by ranges', true),
  _Tool('Organize Pages', Icons.view_carousel_rounded, RouteNames.toolsOrganize, 'Rotate / delete / reorder', true),
  _Tool('Extract Pages', Icons.filter_none_rounded, RouteNames.toolsExtract, 'Extract selected pages', true),
  _Tool('Compress PDF', Icons.compress_rounded, RouteNames.toolsCompress, 'Reduce file size', true),
  _Tool('Image → PDF', Icons.image_rounded, RouteNames.toolsImage2Pdf, 'Images to PDF', true),
  _Tool('PDF → Image', Icons.image_search_rounded, RouteNames.toolsPdf2Image, 'Export pages as images', true),
  _Tool('Sign PDF', Icons.draw_rounded, RouteNames.toolsSign, 'Add signature (native)', false),
];

class ToolGridScreen extends StatelessWidget {
  const ToolGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final cross = width > 700 ? 3 : 2;
    final aspect = width > 700 ? 1.1 : 1.05;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.lunch_dining_rounded, color: scheme.onPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Bento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.onSurface)),
            ]),
            actions: [
              Semantics(
                label: 'About Bento',
                button: true,
                child: IconButton(
                  icon: Icon(Icons.info_outline_rounded, color: scheme.onSurfaceVariant),
                  onPressed: () => context.go('/settings'),
                ),
              ),
            ],
          ),
          // Static header below app bar — no collapse parallax, avoids overflow + jank
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offline PDF toolkit', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  // search — high contrast, solid surfaceContainerHighest
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      Icon(Icons.search_rounded, size: 20, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Search tools…', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text('8 tools', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.onPrimary)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: aspect,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tool = _tools[index];
                  return AnimatedToolCard(
                    label: tool.label,
                    subtitle: tool.subtitle,
                    icon: tool.icon,
                    isEngine: tool.isEngine,
                    delayMs: index * 30,
                    onTap: () => context.goNamed(tool.routeName),
                  );
                },
                childCount: _tools.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
