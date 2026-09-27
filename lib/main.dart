import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/router/app_router.dart';
import 'package:scan/core/theme/dynamic_scheme.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/core/theme/app_theme.dart';
import 'package:scan/core/theme/theme_mode_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BenoApp()));
}

class BenoApp extends ConsumerWidget {
  const BenoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(appPaletteProvider);
    // DynamicColorBuilder supplies the OS Material You schemes (null where
    // unsupported); only AppPalette.dynamic consumes them, everything else
    // ignores them and uses its static scheme.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'Bento',
        theme: AppTheme.lightFor(
          palette,
          dynamicScheme: lightDynamic == null
              ? null
              : toMaterialScheme(lightDynamic),
        ),
        darkTheme: AppTheme.darkFor(
          palette,
          dynamicScheme: darkDynamic == null
              ? null
              : toMaterialScheme(darkDynamic),
        ),
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
