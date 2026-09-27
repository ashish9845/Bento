import 'package:flutter/material.dart';

/// A dashboard shortcut: either navigates to a named route or runs [onTap].
///
/// [keywords] powers the Home search so users don't have to type exact
/// labels — e.g. "password" finds Protect PDF, "shrink" finds Compress.
class HomeShortcut {
  const new({
    required this.id,
    required this.label,
    required this.icon,
    this.routeName,
    this.onTap,
    this.keywords = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final String? routeName;
  final VoidCallback? onTap;
  final List<String> keywords;

  /// True when [query] (already lowercased + trimmed) matches the label or
  /// any keyword, in either direction for partial input.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final labelLower = label.toLowerCase();
    if (labelLower.contains(query) || query.contains(labelLower)) return true;
    for (final keyword in keywords) {
      final k = keyword.toLowerCase();
      if (k.contains(query) || query.contains(k)) return true;
    }
    return false;
  }
}

/// 4-column shortcut grid. Every tile uses the primary theme tint so the
/// whole grid follows the active palette (light + dark safe).
class HomeShortcutGrid extends StatelessWidget {
  const new({required this.shortcuts, required this.onSelect, super.key});

  final List<HomeShortcut> shortcuts;
  final void Function(HomeShortcut shortcut) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = (scheme.primaryContainer, scheme.onPrimaryContainer);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, i) {
        final s = shortcuts[i];
        return RepaintBoundary(
          child: Semantics(
            label: s.label,
            button: true,
            child: InkWell(
              key: ValueKey('home_shortcut_${s.id}'),
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tint.$1,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(s.icon, size: 26, color: tint.$2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
