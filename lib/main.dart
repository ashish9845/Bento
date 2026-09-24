import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/router/app_router.dart';
import 'package:scan/core/server/local_engine_server.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/core/theme/app_theme.dart';
import 'package:scan/core/theme/theme_mode_provider.dart';
import 'package:scan/engine/engine_host.dart';
import 'package:scan/engine/engine_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BenoApp()));
}

class BenoApp extends ConsumerStatefulWidget {
  const BenoApp({super.key});

  @override
  ConsumerState<BenoApp> createState() => _BenoAppState();
}

class _BenoAppState extends ConsumerState<BenoApp> {
  final _engineHostKey = GlobalKey<EngineHostState>();

  @override
  void initState() {
    super.initState();
    // Start engine server off main thread without blocking first frame — 60fps launch per SKILL.md
    Future<void>(() async {
      try {
        await LocalEngineServer.instance.start();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('[main] LocalEngineServer failed to start: $e');
      }
    });
    // Defer setting provider until after first frame so host is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final host = _engineHostKey.currentState;
      if (host != null) {
        ref.read(engineHostProvider.notifier).state = host;
        host.ready.then((_) {
          if (mounted) ref.read(engineHostProvider.notifier).state = host;
        }).catchError((Object e) {
          debugPrint('[BenoApp] engine not ready: $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(appPaletteProvider);
    return MaterialApp.router(
      title: 'Bento',
      theme: AppTheme.lightFor(palette),
      darkTheme: AppTheme.darkFor(palette),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        // Overlay invisible engine host above all routes.
        return Stack(
          children: [
            if (child != null) child,
            // Host must be mounted to initialize WebView; invisible 1x1.
            EngineHost(
              key: _engineHostKey,
              onReady: () {
                final host = _engineHostKey.currentState;
                if (host != null) {
                  ref.read(engineHostProvider.notifier).state = host;
                }
              },
            ),
          ],
        );
      },
    );
  }
}
