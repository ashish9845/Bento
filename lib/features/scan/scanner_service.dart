import 'dart:io';
import 'dart:isolate';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

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
  Future<File> imagesToPdf(List<String> imagePaths) async {
    // Run heavy work in isolate when many/large images to avoid jank
    if (imagePaths.length > 2) {
      final bytes = await Isolate.run(() async {
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
      final out = File('${(await getTemporaryDirectory()).path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await out.writeAsBytes(bytes);
      return out;
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
    final out = File('${(await getTemporaryDirectory()).path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await out.writeAsBytes(await pdf.save());
    return out;
  }
}

/// Plugin-backed impl — cunning_document_scanner 3.0.3 (preferred per docs/scanner-evaluation.md).
class PluginScannerService implements ScannerService {
  @override
  Future<List<String>> scanDocument() async {
    try {
      // ignore: avoid_print
      print('[ScannerService] launching CunningDocumentScanner');
      final result = await CunningDocumentScanner.getPictures();
      // null => user cancelled
      if (result == null) return [];
      return result.whereType<String>().toList();
    } on CunningDocumentScannerException catch (e) {
      debugPrint('[ScannerService] CunningDocumentScannerException ${e.code}: ${e.message}');
      if (e.code == 'permission_denied') {
        throw Exception('Camera permission denied — please allow camera in Settings');
      }
      return [];
    } catch (e) {
      debugPrint('[ScannerService] unexpected $e');
      return [];
    }
  }

  @override
  Future<File> imagesToPdf(List<String> imagePaths) async {
    final pdf = pw.Document();
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      pdf.addPage(pw.Page(build: (ctx) => pw.Center(child: pw.Image(image))));
    }
    final out = File('${(await getTemporaryDirectory()).path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await out.writeAsBytes(await pdf.save());
    return out;
  }
}

/// Fallback platform-channel wrapper (documented in TODO.md Phase 4).
/// Stub — real impl would use MethodChannel to invoke native scanners.
class PlatformChannelScannerService implements ScannerService {
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

  @override
  Future<File> imagesToPdf(List<String> imagePaths) async {
    final pdf = pw.Document();
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      pdf.addPage(pw.Page(build: (ctx) => pw.Center(child: pw.Image(image))));
    }
    final out = File('${(await getTemporaryDirectory()).path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await out.writeAsBytes(await pdf.save());
    return out;
  }
}

final scannerServiceProvider = Provider<ScannerService>((ref) => PluginScannerService());

final scanResultsProvider = StateProvider<List<String>>((ref) => []);
