import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/router/app_router.dart';
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
    return MaterialApp.router(
      title: 'Bento',
      theme: AppTheme.lightFor(palette),
      darkTheme: AppTheme.darkFor(palette),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
