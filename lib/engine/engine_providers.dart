import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/server/local_engine_server.dart';
import 'package:scan/engine/engine_bridge.dart';
import 'package:scan/engine/engine_host.dart';

/// Server lifecycle provider.
final localEngineServerProvider = Provider<LocalEngineServer>((ref) {
  return LocalEngineServer.instance;
});

/// Host state — set by the invisible EngineHost widget via ref.
final engineHostProvider = StateProvider<EngineHostState?>((ref) => null);

final engineBridgeProvider = Provider<EngineBridge?>((ref) {
  final host = ref.watch(engineHostProvider);
  if (host == null || !host.isReady) return null;
  return EngineBridge(hostState: host);
});

final engineReadyProvider = Provider<bool>((ref) {
  final host = ref.watch(engineHostProvider);
  return host?.isReady ?? false;
});
