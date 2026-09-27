import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scan/core/router/route_names.dart';
import 'package:scan/core/widgets/animated_tool_card.dart';

class _Tool {
  const new(this.label, this.icon, this.routeName, this.subtitle);
  final String label;
  final IconData icon;
  final String routeName;
  final String subtitle;
}

/// A Tools-tab section. Only "Most popular" exists while the catalogue is
/// small — add more (e.g. "Security", "Convert") as tools grow, each with
/// its own header + grid below.
class _ToolCategory {
  const new(this.title, this.tools);
  final String title;
  final List<_Tool> tools;
}

const _categories = [
  _ToolCategory('Most popular', [
    _Tool(
      'Merge PDFs',
      Icons.merge_rounded,
      RouteNames.toolsMerge,
      'Combine multiple PDFs',
    ),
    _Tool(
      'Split PDF',
      Icons.content_cut_rounded,
      RouteNames.toolsSplit,
      'Split by ranges',
    ),
    _Tool(
      'Organize Pages',
      Icons.view_carousel_rounded,
      RouteNames.toolsOrganize,
      'Rotate / delete / reorder',
    ),
    _Tool(
      'Extract Pages',
      Icons.filter_none_rounded,
      RouteNames.toolsExtract,
      'Extract selected pages',
    ),
    _Tool(
      'Compress PDF',
      Icons.compress_rounded,
      RouteNames.toolsCompress,
      'Reduce file size',
    ),
    _Tool(
      'Image → PDF',
      Symbols.picture_as_pdf,
      RouteNames.toolsImage2Pdf,
      'Images to PDF',
    ),
    _Tool(
      'PDF → Image',
      Icons.image_search_rounded,
      RouteNames.toolsPdf2Image,
      'Export pages as images',
    ),
    _Tool(
      'Protect PDF',
      Symbols.add_moderator,
      RouteNames.toolsProtect,
      'Password + AES-256',
    ),
    _Tool(
      'Unlock PDF',
      Symbols.encrypted_off,
      RouteNames.toolsUnlock,
      'Remove password',
    ),
    _Tool(
      'Sign PDF',
      Symbols.stylus_note,
      RouteNames.toolsSign,
      'Add signature (native)',
    ),
  ]),
];

class ToolGridScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ToolGridScreen> createState() => _ToolGridScreenState();
}

class _ToolGridScreenState extends State<ToolGridScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Tools whose label or subtitle matches [query]: exact/contains first,
  /// then fuzzy (subsequence for abbreviations like "mrg", edit distance
  /// for typos like "mrege"), checked per word token.
  bool _matches(_Tool tool, String query) {
    if (query.isEmpty) return true;
    final fields = [tool.label.toLowerCase(), tool.subtitle.toLowerCase()];
    for (final hay in fields) {
      if (hay.contains(query) || query.contains(hay)) return true;
    }
    final tokens = [
      for (final f in fields) ...f.split(RegExp('[^a-z]+')),
      fields.join().replaceAll(RegExp('[^a-z]+'), ''),
    ].where((t) => t.isNotEmpty);
    for (final token in tokens) {
      if (_isSubsequence(query, token)) return true;
      if (query.length >= 3 &&
          _levenshtein(query, token, _maxDistance(query.length))) {
        return true;
      }
    }
    return false;
  }

  /// True when every char of [query] appears in [token] in order
  /// ("cmpress" matches "compress", "mrg" matches "merge").
  bool _isSubsequence(String query, String token) {
    var j = 0;
    for (var i = 0; i < token.length && j < query.length; i++) {
      if (token[i] == query[j]) j++;
    }
    return j == query.length;
  }

  /// Edit-distance budget that grows with query length (short queries stay
  /// strict so single letters don't match everything).
  int _maxDistance(int queryLength) => queryLength <= 4 ? 1 : 2;

  /// True when [query] is within [max] edits of [token]. Bails out early
  /// when the length gap alone exceeds the budget.
  bool _levenshtein(String query, String token, int max) {
    if ((query.length - token.length).abs() > max) return false;
    var prev = List.generate(token.length + 1, (j) => j);
    for (var i = 1; i <= query.length; i++) {
      final curr = [i, ...List.filled(token.length, 0)];
      var rowMin = curr[0];
      for (var j = 1; j <= token.length; j++) {
        final cost = query[i - 1] == token[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
        if (curr[j] < rowMin) rowMin = curr[j];
      }
      if (rowMin > max) return false;
      prev = curr;
    }
    return prev[token.length] <= max;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Launcher-style grid: 4 icon tiles per row, names underneath.
    // Cells stay compact (aspect < 1) so the grid doesn't sprawl.
    const cross = 4;
    const aspect = 0.72;
    final q = _query.trim().toLowerCase();
    final visible = [
      for (final cat in _categories)
        _ToolCategory(cat.title, [
          for (final t in cat.tools)
            if (_matches(t, q)) t,
        ]),
    ].where((cat) => cat.tools.isNotEmpty).toList();
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
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lunch_dining_rounded,
                    color: scheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Bento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              Semantics(
                label: 'About Bento',
                button: true,
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
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
                  Text(
                    'Offline PDF toolkit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // search — high contrast, solid surfaceContainerHighest
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            key: const ValueKey('tools_search_field'),
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search tools…',
                              border: InputBorder.none,
                              hintStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '10 tools',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Text(
                  'No tools match "$_query"',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          for (var c = 0; c < visible.length; c++) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, c == 0 ? 8 : 20, 16, 4),
                child: Text(
                  visible[c].title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: aspect,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tool = visible[c].tools[index];
                  return AnimatedToolCard(
                    key: ValueKey('tool_card_${tool.routeName}'),
                    label: tool.label,
                    subtitle: tool.subtitle,
                    icon: tool.icon,
                    delayMs: (c * 100) + (index * 30),
                    onTap: () => context.goNamed(tool.routeName),
                  );
                }, childCount: visible[c].tools.length),
              ),
            ),
          ],
          // Footer note in bundled Pixelify Sans (OFL, see assets/fonts/OFL.txt).
          // Hidden while searching so it never crowds an empty result.
          if (q.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                child: Text(
                  'More tools Coming soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.3,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
