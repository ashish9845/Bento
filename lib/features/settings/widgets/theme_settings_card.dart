import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/theme/app_palette_cubit.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/core/theme/dynamic_scheme.dart';
import 'package:scan/core/theme/theme_mode_cubit.dart';

import 'app_theme_preview.dart';

String _modeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
}

/// Theme section: collapsible card with a "Mode · Palette" subtitle, Dark /
/// Light / System pills, and a horizontally swipeable row of palette
/// previews. Replaces the old segmented button + color-dot wrap.
class ThemeSettingsCard extends StatefulWidget {
  const new({super.key});

  @override
  State<ThemeSettingsCard> createState() => _ThemeSettingsCardState();
}

class _ThemeSettingsCardState extends State<ThemeSettingsCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mode = context.watch<ThemeModeCubit>().state;
    final palette = context.watch<AppPaletteCubit>().state;
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_modeLabel(mode)} · ${palette.label}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    tooltip: _expanded ? 'Collapse' : 'Expand',
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final m in [
                      ThemeMode.dark,
                      ThemeMode.light,
                      ThemeMode.system,
                    ])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: m == ThemeMode.dark ? 0 : 4,
                            right: m == ThemeMode.system ? 0 : 4,
                          ),
                          child: _ModePill(
                            label: _modeLabel(m),
                            selected: mode == m,
                            onTap: () =>
                                context.read<ThemeModeCubit>().setMode(m),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'App Theme',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                // OS dynamic colors for the Dynamic preview (null where
                // unsupported → palette falls back to Default).
                DynamicColorBuilder(
                  builder: (lightDynamic, darkDynamic) {
                    final isLight =
                        Theme.of(context).brightness == Brightness.light;
                    final rawDynamic = isLight ? lightDynamic : darkDynamic;
                    final dynamicScheme = rawDynamic == null
                        ? null
                        : toMaterialScheme(rawDynamic);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final p in AppPalette.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: AppThemePreview(
                                palette: p,
                                scheme: p.resolve(
                                  isLight ? Brightness.light : Brightness.dark,
                                  dynamicScheme: dynamicScheme,
                                ),
                                selected: p == palette,
                                onTap: () => context
                                    .read<AppPaletteCubit>()
                                    .setPalette(p),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One Dark/Light/System pill — filled primary when selected, quiet surface
/// otherwise, like a segmented control but with full-width thirds.
class _ModePill extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label mode',
      button: true,
      selected: selected,
      child: InkWell(
        key: ValueKey('theme_mode_${label.toLowerCase()}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
