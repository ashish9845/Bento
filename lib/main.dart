import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/error/app_bloc_observer.dart';
import 'package:scan/core/error/error_reporting.dart';
import 'package:scan/core/router/app_router.dart';
import 'package:scan/core/storage/storage_location.dart';
import 'package:scan/features/settings/cubit/crash_reporting_cubit.dart';
import 'package:scan/core/theme/app_palette_cubit.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/core/theme/app_theme.dart';
import 'package:scan/core/theme/dynamic_scheme.dart';
import 'package:scan/core/theme/theme_mode_cubit.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// DSN injected at build time: `--dart-define=SENTRY_DSN=https://…`.
/// Empty (default) disables sending — errors still hit the console.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  // Framework errors (layout, build, …): keep the console dump, also report.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorReporting.report(
      details.exception,
      details.stack,
      context: 'flutter',
      fatal: !details.silent,
    );
  };
  // Async/platform errors outside the framework: report, claim handled.
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    ErrorReporting.report(error, stack, context: 'platform', fatal: true);
    return true;
  };
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.tracesSampleRate = 0.1;
    },
    appRunner: () => runApp(const BenoApp()),
  );
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
        BlocProvider(create: (_) => CrashReportingCubit()),
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
