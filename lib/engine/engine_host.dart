import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scan/core/server/local_engine_server.dart';

/// Invisible InAppWebView hosting the headless BentoPDF engine.
///
/// Per AGENTS.md: never shown to user, loads http://127.0.0.1:<port>/engine.html
/// with COOP/COEP headers. Provides JS evaluation channel for `EngineBridge`.
class EngineHost extends StatefulWidget {
  const EngineHost({super.key, this.onReady});

  final VoidCallback? onReady;

  @override
  State<EngineHost> createState() => EngineHostState();
}

class EngineHostState extends State<EngineHost> {
  InAppWebViewController? _controller;
  final Completer<void> _readyCompleter = Completer<void>();

  Future<void> get ready => _readyCompleter.future;
  InAppWebViewController? get controller => _controller;
  bool get isReady => _readyCompleter.isCompleted;

  @override
  Widget build(BuildContext context) {
    final baseUrl = LocalEngineServer.instance.baseUrl;
    if (baseUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // Offstage invisible — does not repaint main UI, avoids Opacity layer cost.
    return Offstage(
      child: SizedBox(
        width: 1,
        height: 1,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri('$baseUrl/engine.html')),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            transparentBackground: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStop: (controller, url) async {
            // Poll for BentoEngineReady flag set by engine.html.
            for (var i = 0; i < 50; i++) {
              final ready = await controller.evaluateJavascript(
                source: 'typeof window.BentoEngineReady !== "undefined"',
              );
              if (ready == true) {
                if (!_readyCompleter.isCompleted) {
                  _readyCompleter.complete();
                  widget.onReady?.call();
                }
                if (kDebugMode) {
                  final sab = await controller.evaluateJavascript(
                    source: 'typeof SharedArrayBuffer !== "undefined"',
                  );
                  debugPrint('[EngineHost] ready, SharedArrayBuffer: $sab');
                }
                return;
              }
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }
            if (!_readyCompleter.isCompleted) {
              _readyCompleter.completeError(
                StateError('BentoEngineReady not set within timeout'),
              );
            }
          },
          onConsoleMessage: (controller, message) {
            if (kDebugMode) {
              debugPrint('[EngineHost console] ${message.message}');
            }
          },
        ),
      ),
    );
  }

  Future<dynamic> evaluateJavascript(String source) async {
    await ready;
    return _controller?.evaluateJavascript(source: source);
  }
}
