import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scan/core/server/local_engine_server.dart';
import 'package:scan/engine/engine_host.dart';

/// Typed Dart↔JS bridge calling into window.BentoEngine.
///
/// Input files are passed as local file URLs served by [LocalEngineServer]
/// (http://127.0.0.1:<port>/files/<name>) — not base64 — to avoid large
/// in-memory payloads per AGENTS.md.
///
/// Output file URLs returned by JS are fetched via HTTP and written to temp.
class EngineBridge {
  EngineBridge({required this.hostState});

  final EngineHostState hostState;

  Future<String> _fileToUrl(File file) async {
    final filesDir = await LocalEngineServer.instance.filesDirectory;
    final name =
        '${DateTime.now().microsecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final dest = File('${filesDir.path}/$name');
    await file.copy(dest.path);
    return '${LocalEngineServer.instance.baseUrl}/files/$name';
  }

  Future<File> _urlToFile(String url) async {
    final uri = Uri.parse(url);
    // If engine returned a /files/ URL, use it directly; otherwise treat as
    // host-relative.
    final resolved = url.startsWith('http')
        ? uri
        : Uri.parse('${LocalEngineServer.instance.baseUrl}/$url');

    final response = await http.get(resolved);
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to fetch engine result: ${response.statusCode} $resolved',
      );
    }
    final tempDir = await getTemporaryDirectory();
    final outName =
        'result_${DateTime.now().microsecondsSinceEpoch}.pdf';
    final outFile = File('${tempDir.path}/$outName');
    await outFile.writeAsBytes(response.bodyBytes);
    return outFile;
  }

  // ---------------------------------------------------------------------------
  // Tool wrappers — 7 engine-backed v1 tools (Sign is native, not here)
  // ---------------------------------------------------------------------------

  /// Compress a PDF — the spike tool that needs SharedArrayBuffer.
  Future<File> compress(File input, {String quality = 'medium'}) async {
    final url = await _fileToUrl(input);
    final js =
        'window.BentoEngine.compress(${_jsStr(url)}, ${_jsStr(quality)})';
    final resultUrl = await _evalString(js);
    debugPrint('[EngineBridge] compress -> $resultUrl');
    return _urlToFile(resultUrl);
  }

  Future<File> merge(List<File> inputs) async {
    final urls = await Future.wait(inputs.map(_fileToUrl));
    final js =
        'window.BentoEngine.merge(${_jsArr(urls)})';
    final resultUrl = await _evalString(js);
    return _urlToFile(resultUrl);
  }

  Future<List<File>> split(File input, List<String> ranges) async {
    final url = await _fileToUrl(input);
    final js =
        // ignore: noop_primitive_operations
        'window.BentoEngine.split(${_jsStr(url)}, ${_jsArr(ranges)})';
    final result = await hostState.evaluateJavascript(js);
    final urls = (result as List).cast<String>();
    return Future.wait(urls.map(_urlToFile));
  }

  Future<File> organize(File input, List<Map<String, dynamic>> ops) async {
    final url = await _fileToUrl(input);
    // ops e.g. [{"type":"rotate","page":0,"angle":90}]
    final js =
        // ignore: noop_primitive_operations
        'window.BentoEngine.organize(${_jsStr(url)}, ${ops.toString()})';
    final resultUrl = await _evalString(js);
    return _urlToFile(resultUrl);
  }

  Future<File> extract(File input, List<int> pages) async {
    final url = await _fileToUrl(input);
    final pagesStr = pages.toString();
    final js =
        'window.BentoEngine.extract(${_jsStr(url)}, $pagesStr)';
    final resultUrl = await _evalString(js);
    return _urlToFile(resultUrl);
  }

  Future<File> imageToPdf(List<File> images) async {
    final urls = await Future.wait(images.map(_fileToUrl));
    final js = 'window.BentoEngine.imageToPdf(${_jsArr(urls)})';
    final resultUrl = await _evalString(js);
    return _urlToFile(resultUrl);
  }

  Future<List<File>> pdfToImage(File input) async {
    final url = await _fileToUrl(input);
    final js = 'window.BentoEngine.pdfToImage(${_jsStr(url)})';
    final result = await hostState.evaluateJavascript(js);
    final urls = (result as List).cast<String>();
    return Future.wait(urls.map(_urlToFile));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<String> _evalString(String js) async {
    final result = await hostState.evaluateJavascript(js);
    if (result == null) {
      throw StateError('Engine returned null for: $js');
    }
    return result.toString();
  }

  String _jsStr(String s) => "'${s.replaceAll("'", r"\'")}'";
  String _jsArr(List<String> items) =>
      '[${items.map(_jsStr).join(',')}]';
}
