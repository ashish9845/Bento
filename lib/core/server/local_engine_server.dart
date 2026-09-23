// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// Local shelf server serving `assets/engine/` with COOP/COEP headers.
///
/// Required for `SharedArrayBuffer` needed by LibreOffice-based tools
/// (Compress). See AGENTS.md headless engine section.
/// Files are exposed via `/files/<name>` to avoid base64 blobs.
class LocalEngineServer {
  HttpServer? _server;

  int get port => _server?.port ?? 0;
  String get baseUrl =>
      _server == null ? '' : 'http://127.0.0.1:$port';
  bool get isRunning => _server != null;

  static final LocalEngineServer instance = LocalEngineServer._();
  LocalEngineServer._();

  Future<void> start() async {
    if (isRunning) return;

    final tempDir = await getTemporaryDirectory();
    final engineDir = Directory('${tempDir.path}/bento_engine');
    final filesDir = Directory('${tempDir.path}/bento_files');
    await engineDir.create(recursive: true);
    await filesDir.create(recursive: true);

    // Copy bundled assets/engine/ to tempDir/bento_engine if needed.
    // Placeholder engine.html is created if no assets exist yet (Phase 2 before bundle built).
    await _ensureEngineAssets(engineDir);

    final engineHandler = createStaticHandler(
      engineDir.path,
      defaultDocument: 'engine.html',
    );

    final filesHandler = createStaticHandler(
      filesDir.path,
    );

    // Upload handler: POST /files/<name> writes bytes, returns URL
    Future<Response> uploadHandler(Request request) async {
      final segs = request.url.pathSegments;
      if (segs.isEmpty || segs.first != 'files' || request.method != 'POST') {
        return Response.notFound('not found');
      }
      final name = segs.length > 1 ? segs.sublist(1).join('/') : 'upload_${DateTime.now().millisecondsSinceEpoch}';
      final bytes = await request.read().expand((e) => e).toList();
      final outFile = File('${filesDir.path}/$name');
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(bytes);
      final url = '${LocalEngineServer.instance.baseUrl}/files/$name';
      return Response.ok(url, headers: {'content-type': 'text/plain'});
    }

    Handler handler = (Request request) async {
      // Upload path takes precedence for POST
      if (request.url.pathSegments.isNotEmpty &&
          request.url.pathSegments.first == 'files' &&
          request.method == 'POST') {
        return uploadHandler(request);
      }
      if (request.url.path.startsWith('files/') ||
          request.url.path == 'files') {
        return filesHandler(request);
      }
      return engineHandler(request);
    };

    handler = const Pipeline()
        .addMiddleware(_coopCoepMiddleware)
        .addMiddleware(logRequests())
        .addHandler(handler);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      0, // random free port
    );
    print('[LocalEngineServer] serving at $baseUrl');
    print('[LocalEngineServer] engine: ${engineDir.path}');
    print('[LocalEngineServer] files: ${filesDir.path}');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  /// Directory where callers should write input PDFs for engine consumption.
  Future<Directory> get filesDirectory async {
    final tempDir = await getTemporaryDirectory();
    return Directory('${tempDir.path}/bento_files');
  }

  static Middleware get _coopCoepMiddleware => (Handler inner) {
        return (Request request) async {
          final response = await inner(request);
          return response.change(headers: {
            'Cross-Origin-Opener-Policy': 'same-origin',
            'Cross-Origin-Embedder-Policy': 'require-corp',
            'Cross-Origin-Resource-Policy': 'cross-origin',
            ...response.headers,
          });
        };
      };

  Future<void> _ensureEngineAssets(Directory engineDir) async {
    final indexFile = File('${engineDir.path}/engine.html');
    if (await indexFile.exists()) return;

    // Try to load from bundled assets; if not yet built (Phase 2 pending),
    // write a placeholder that exposes a stub BentoEngine.
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final hasEngine = manifest.contains('assets/engine/');
      if (hasEngine) {
        // Real extraction would iterate manifest and copy each asset.
        // For now, placeholder — Phase 2 will replace with Vite bundle.
      }
    } catch (_) {
      // No manifest in test or before assets built.
    }

    await indexFile.writeAsString(_placeholderEngineHtml);
  }

  static const _placeholderEngineHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Bento Engine (placeholder)</title>
</head>
<body>
<script>
// Placeholder until Phase 2 Vite bundle is built.
// Exposes stub functions so Dart bridge can verify COOP/COEP + SharedArrayBuffer.
window.BentoEngine = {
  _ready: true,
  _placeholder: true,
  merge: async (fileUrls) => { console.log('[BentoEngine.placeholder] merge', fileUrls); return fileUrls[0] ?? ''; },
  split: async (fileUrl, ranges) => { console.log('[BentoEngine.placeholder] split', fileUrl, ranges); return [fileUrl]; },
  organize: async (fileUrl, ops) => { console.log('[BentoEngine.placeholder] organize', fileUrl, ops); return fileUrl; },
  extract: async (fileUrl, pages) => { console.log('[BentoEngine.placeholder] extract', fileUrl, pages); return fileUrl; },
  compress: async (fileUrl, opts) => { console.log('[BentoEngine.placeholder] compress', fileUrl, opts); return fileUrl; },
  imageToPdf: async (fileUrls) => { console.log('[BentoEngine.placeholder] imageToPdf', fileUrls); return fileUrls[0] ?? ''; },
  pdfToImage: async (fileUrl) => { console.log('[BentoEngine.placeholder] pdfToImage', fileUrl); return [fileUrl]; },
};
window.BentoEngineReady = true;
console.log('[BentoEngine] placeholder ready, SharedArrayBuffer:', typeof SharedArrayBuffer !== 'undefined');
</script>
</body>
</html>
''';
}
