import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:scan/core/storage/storage_location.dart';

/// Abstraction over native scanner plugins.
///
/// Phase 4 spike evaluates 2-3 plugins:
///   cunning_document_scanner, flutter_doc_scanner, document_scanner
/// Fallback: thin platform-channel wrapper (~200 LOC)
///   Android GmsDocumentScanner, iOS VNDocumentCameraViewController
abstract class ScannerService {
  /// Launch native scanner, return temp image paths (or PDF path).
  Future<List<String>> scanDocument();

  /// Compose image paths to PDF via `pdf` + `image` (native, no engine) — off main thread for 60fps.
  /// Saves once to the save directory (custom/default Documents) with [outputName].
  Future<File> imagesToPdf(List<String> imagePaths, {String? outputName}) async {
    // Run heavy work in isolate when many/large images to avoid jank
    Future<Uint8List> buildPdf() async {
      if (imagePaths.length > 2) {
        return Isolate.run(() async {
          final pdf = pw.Document();
          for (final path in imagePaths) {
            final b = await File(path).readAsBytes();
            final decoded = img.decodeImage(b);
            if (decoded == null) continue;
            final image = pw.MemoryImage(b);
            pdf.addPage(pw.Page(build: (ctx) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain))));
          }
          return pdf.save();
        });
      }
      final pdf = pw.Document();
      for (final path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded == null) continue;
        final image = pw.MemoryImage(bytes);
        pdf.addPage(pw.Page(
          build: (ctx) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ));
      }
      return pdf.save();
    }

    final outBytes = await buildPdf();
    final saveDir = (await getSaveDirectory()).path;
    var baseName = outputName?.trim() ?? 'scan_${DateTime.now().millisecondsSinceEpoch}';
    if (!baseName.toLowerCase().endsWith('.pdf')) baseName = '$baseName.pdf';
    baseName = baseName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    var outFile = File('$saveDir/$baseName');
    var counter = 1;
    while (await outFile.exists()) {
      final nameNoExt = baseName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
      outFile = File('$saveDir/${nameNoExt}_$counter.pdf');
      counter++;
    }
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }
}

/// Thrown when the user backs out of the native scanner UI.
class ScanCancelledException implements Exception {
  const ScanCancelledException();
}

/// Thrown when camera permission is denied (asks caller to guide to Settings).
class ScanPermissionException implements Exception {
  final String message;
  const ScanPermissionException(this.message);
  @override
  String toString() => message;
}

/// Plugin-backed impl — cunning_document_scanner 3.0.3 (preferred per docs/scanner-evaluation.md).
///
/// Throws [ScanCancelledException] on user cancel, [ScanPermissionException]
/// on camera denial, and [Exception] with the native error code/message
/// otherwise — never silently returns [] on failure.
class PluginScannerService extends ScannerService {
  @override
  Future<List<String>> scanDocument() async {
    // ignore: avoid_print
    print('[ScannerService] launching CunningDocumentScanner');
    try {
      final result = await CunningDocumentScanner.getPictures();
      // null => user cancelled
      if (result == null) throw const ScanCancelledException();
      final paths = result.whereType<String>().toList();
      // ignore: avoid_print
      print('[ScannerService] scanned ${paths.length} page(s)');
      return paths;
    } on ScanCancelledException {
      rethrow;
    } on CunningDocumentScannerException catch (e) {
      debugPrint('[ScannerService] CunningDocumentScannerException ${e.code}: ${e.message}');
      if (e.code == 'permission_denied') {
        throw const ScanPermissionException(
            'Camera permission denied — allow camera access to scan documents');
      }
      throw Exception('Scanner failed [${e.code}]: ${e.message}');
    } catch (e) {
      debugPrint('[ScannerService] unexpected $e');
      if (e is MissingPluginException) {
        throw Exception('Scanner plugin not available — reinstall the app');
      }
      throw Exception('Scanner failed: $e');
    }
  }

}

/// Fallback platform-channel wrapper (documented in TODO.md Phase 4).
/// Stub — real impl would use MethodChannel to invoke native scanners.
class PlatformChannelScannerService extends ScannerService {
  static const _channel = 'com.benopdf.scan/scanner';
  @override
  Future<List<String>> scanDocument() async {
    try {
      const channel = MethodChannel(_channel);
      final result = await channel.invokeMethod<List<dynamic>>('scanDocument');
      return result?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('[PlatformChannelScannerService] $e');
      return [];
    }
  }

}

final scannerServiceProvider = Provider<ScannerService>((ref) => PluginScannerService());

final scanResultsProvider = StateProvider<List<String>>((ref) => []);
