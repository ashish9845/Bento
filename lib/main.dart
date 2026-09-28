import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/router/app_router.dart';
import 'package:scan/core/storage/storage_location.dart';
import 'package:scan/core/theme/app_palette_cubit.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/core/theme/app_theme.dart';
import 'package:scan/core/theme/dynamic_scheme.dart';
import 'package:scan/core/theme/theme_mode_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BenoApp());
}

class BenoApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeModeCubit()),
          BlocProvider(create: (_) => AppPaletteCubit()),
          BlocProvider(create: (_) => StorageLocationCubit()),
        ],
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) =>
              BlocBuilder<AppPaletteCubit, AppPalette>(
                builder: (context, palette) {
                  // DynamicColorBuilder supplies the OS Material You schemes
                  // (null where unsupported); only AppPalette.dynamic consumes
                  // them, everything else ignores them and uses its static scheme.
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
                },
              ),
      ),
    );
  }
}
