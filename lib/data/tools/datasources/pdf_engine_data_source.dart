import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import '../../../core/storage/storage_location.dart';

/// Parses UI range specs like "1-3, 5, 7-end" (1-based, "end" = last page)
/// into 0-based page-index chunks. Throws [FormatException] on bad input.
List<List<int>> parsePageRanges(String spec, int pageCount) {
  final chunks = <List<int>>[];
  for (final rawPart in spec.split(',')) {
    final part = rawPart.trim().toLowerCase();
    if (part.isEmpty) continue;
    if (part.contains('-')) {
      final bounds = part.split('-');
      if (bounds.length != 2) {
        throw FormatException('Bad range "$rawPart" — use like 1-3');
      }
      final start = _parsePageNumber(bounds[0].trim(), pageCount, rawPart) - 1;
      final end = bounds[1].trim() == 'end'
          ? pageCount
          : _parsePageNumber(bounds[1].trim(), pageCount, rawPart);
      if (start < 0 || end > pageCount || start >= end) {
        throw FormatException('Range "$rawPart" is outside 1-$pageCount');
      }
      chunks.add([for (var i = start; i < end; i++) i]);
    } else {
      final page = _parsePageNumber(part, pageCount, rawPart) - 1;
      chunks.add([page]);
    }
  }
  if (chunks.isEmpty) {
    throw const FormatException('Enter at least one range, e.g. 1-2, 3, 4-end');
  }
  return chunks;
}

int _parsePageNumber(String token, int pageCount, String rawPart) {
  final n = int.tryParse(token);
  if (n == null || n < 1 || n > pageCount) {
    throw FormatException('"$rawPart" is outside 1-$pageCount');
  }
  return n;
}

/// Native PDF engine backed by `pdf_manipulator` (MIT-licensed Rust core
/// over FFI — no WebView, no JS, no WASM). One shared [Pdf] instance, every
/// operation already runs off the main thread inside the engine.
abstract class PdfEngineDataSource {
  Future<int> pageCount(File input);
  Future<File> merge(List<File> inputs);
  Future<List<File>> split(File input, String rangesSpec, {String? baseName});
  Future<File> extract(File input, List<int> pages);
  Future<File> organize(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
  });
  Future<File> compress(File input, PdfImagePolicy policy);
  Future<File> imagesToPdf(List<File> images, {String? outputName});
  Future<List<File>> renderPages(File input, {int maxSize = 1440});
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
  });
  Future<void> saveToCustomLocation(File file);
}

class PdfEngineDataSourceImpl implements PdfEngineDataSource {
  /// Shared engine instance reused everywhere (per package guidance).
  static final Pdf _pdf = Pdf();

  Future<File> _outputFile(String prefix, {String? name, String extension = 'pdf'}) async {
    final dir = (await getSaveDirectory()).path;
    String base = (name?.trim().isNotEmpty == true ? name!.trim() : '${prefix}_${DateTime.now().millisecondsSinceEpoch}');
    if (!base.toLowerCase().endsWith('.$extension')) base = '$base.$extension';
    base = base.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    var out = File('$dir/$base');
    var counter = 1;
    while (await out.exists()) {
      final stem = base.replaceAll(RegExp('\\.$extension\$', caseSensitive: false), '');
      out = File('$dir/${stem}_$counter.$extension');
      counter++;
    }
    return out;
  }

  Never _wrap(Object e) {
    if (e is PdfPasswordRequired) {
      throw Exception('This PDF is password-protected — decrypt it first');
    }
    if (e is PdfWrongPassword) {
      throw Exception('Wrong password for this PDF');
    }
    if (e is PdfCorrupted) {
      throw Exception('This file is not a valid PDF (corrupted)');
    }
    if (e is PdfError) {
      throw Exception(e.message);
    }
    throw Exception(e.toString().replaceFirst('Exception: ', ''));
  }

  @override
  Future<int> pageCount(File input) async {
    try {
      final doc = await _pdf.open(FileSource(input));
      try {
        return doc.pageCount;
      } finally {
        await doc.dispose();
      }
    } catch (e) {
      _wrap(e);
    }
  }

  @override
  Future<File> merge(List<File> inputs) async {
    if (inputs.length < 2) throw Exception('Pick at least 2 PDFs to merge');
    final out = await _outputFile('merged');
    final sink = await FileSink.create(out);
    try {
      await _pdf.merge(inputs.map(FileSource.new).toList(), sink);
    } catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    return out;
  }

  @override
  Future<List<File>> split(File input, String rangesSpec, {String? baseName}) async {
    final count = await pageCount(input);
    final chunks = parsePageRanges(rangesSpec, count);
    final stem = (baseName?.trim().isNotEmpty == true
            ? baseName!.trim()
            : input.path.split('/').last.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), ''))
        .replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final results = <File>[];
    for (var i = 0; i < chunks.length; i++) {
      final out = await _outputFile('${stem}_part${i + 1}');
      final sink = await FileSink.create(out);
      try {
        await _pdf.extractPages(FileSource(input), sink, pages: chunks[i]);
      } catch (e) {
        _wrap(e);
      } finally {
        await sink.close();
      }
      results.add(out);
    }
    return results;
  }

  @override
  Future<File> extract(File input, List<int> pages) async {
    if (pages.isEmpty) throw Exception('Select at least one page to extract');
    final out = await _outputFile('extracted');
    final sink = await FileSink.create(out);
    try {
      await _pdf.extractPages(FileSource(input), sink, pages: [...pages]..sort());
    } catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    return out;
  }

  @override
  Future<File> organize(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
  }) async {
    final count = await pageCount(input);
    // Final order in original indices: explicit order (minus deleted) or natural.
    final natural = [for (var i = 0; i < count; i++) i];
    final finalOrder = (order ?? natural).where((i) => !delete.contains(i)).toList();
    if (finalOrder.isEmpty) throw Exception('Deleting every page would leave an empty PDF');
    // Remap rotations (tracked on original indices) into post-delete positions.
    final newRotations = <int, int>{};
    for (final entry in rotations.entries) {
      if (delete.contains(entry.key)) continue;
      final newIndex = finalOrder.indexOf(entry.key);
      if (newIndex != -1 && entry.value % 360 != 0) {
        newRotations[newIndex] = (newRotations[newIndex] ?? 0) + entry.value;
      }
    }
    final out = await _outputFile('organized');
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input));
      if (finalOrder.length != count || !_isNaturalOrder(finalOrder, count)) {
        await editor.selectPages(finalOrder);
      } else if (delete.isNotEmpty) {
        await editor.selectPages(finalOrder);
      }
      for (final entry in newRotations.entries) {
        await editor.rotatePage(entry.key, degrees: entry.value % 360);
      }
      await editor.save(sink);
    } catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    return out;
  }

  bool _isNaturalOrder(List<int> order, int count) {
    if (order.length != count) return false;
    for (var i = 0; i < count; i++) {
      if (order[i] != i) return false;
    }
    return true;
  }

  @override
  Future<File> compress(File input, PdfImagePolicy policy) async {
    final out = await _outputFile('compressed');
    final sink = await FileSink.create(out);
    try {
      await _pdf.compress(FileSource(input), sink, images: policy);
    } catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    return out;
  }

  @override
  Future<File> imagesToPdf(List<File> images, {String? outputName}) async {
    if (images.isEmpty) throw Exception('Pick at least one image');
    final out = await _outputFile('images', name: outputName);
    final sink = await FileSink.create(out);
    try {
      await _pdf.imagesToPdf(images.map(FileSource.new).toList(), sink);
    } catch (e) {
      _wrap(e);
    } finally {
      await sink.close();
    }
    return out;
  }

  @override
  Future<List<File>> renderPages(File input, {int maxSize = 1440}) async {
    final rawStem = input.path.split('/').last.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
    final sanitized = rawStem.replaceAll(RegExp(r'[^\w\-. ]'), '_');
    final safeStem = sanitized.isEmpty ? 'pdf_images' : sanitized;
    final baseDir = (await getSaveDirectory()).path;
    // One folder per PDF: <saveDir>/<pdf-name>/p1.png, p2.png, …
    var folder = Directory('$baseDir/$safeStem');
    var folderCounter = 1;
    while (await folder.exists()) {
      folder = Directory('$baseDir/${safeStem}_$folderCounter');
      folderCounter++;
    }
    await folder.create(recursive: true);
    final doc = await _pdf.open(FileSource(input));
    final results = <File>[];
    final failures = <int>[];
    try {
      final count = doc.pageCount;
      if (count < 1) throw Exception('This PDF has no pages');
      // Render page-by-page so one bad page can't poison the whole export.
      for (var i = 0; i < count; i++) {
        try {
          var rendered = false;
          await for (final page in doc.render(
            pages: PdfPages.single(i),
            size: PdfRenderSize(maxWidth: maxSize, maxHeight: maxSize),
          )) {
            if (page.data.isEmpty) {
              throw Exception('renderer returned no data');
            }
            final out = File('${folder.path}/p${i + 1}.png');
            await out.writeAsBytes(page.data, flush: true);
            final len = await out.length();
            if (len == 0) {
              try {
                await out.delete();
              } catch (_) {}
              throw Exception('write produced an empty file');
            }
            debugPrint('[PdfEngine] rendered page ${i + 1}/$count: ${page.width}x${page.height}, $len bytes');
            results.add(out);
            rendered = true;
          }
          if (!rendered) throw Exception('renderer returned no pages');
        } catch (e) {
          debugPrint('[PdfEngine] page ${i + 1} failed: $e');
          failures.add(i + 1);
        }
      }
    } catch (e) {
      _wrap(e);
    } finally {
      await doc.dispose();
    }
    if (results.isEmpty) {
      // Never leave empty folders or 0-byte files behind.
      try {
        await folder.delete(recursive: true);
      } catch (_) {}
      if (failures.isNotEmpty) {
        throw Exception('Could not render page(s) ${failures.join(', ')} from this PDF');
      }
      throw Exception('No pages could be rendered from this PDF');
    }
    return results;
  }

  @override
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
  }) async {
    final count = await pageCount(input);
    final targetPage = page.clamp(0, count - 1);
    // Preserve the drawn aspect ratio so the signature never stretches.
    var aspect = 2.0;
    try {
      final decoded = img.decodeImage(signaturePng);
      if (decoded != null && decoded.height > 0) {
        aspect = decoded.width / decoded.height;
      }
    } catch (_) {}
    final out = await _outputFile('signed');
    final sink = await FileSink.create(out);
    PdfEditor? editor;
    try {
      editor = await _pdf.edit(FileSource(input));
      final media = await editor.pageMediaBox(targetPage);
      final w = widthPts;
      final h = w / aspect;
      const margin = 36.0;
      await editor.addImageStamp(
        targetPage,
        MemorySource(signaturePng),
        rect: PdfRect(
          x: (media.x + media.width - margin - w).clamp(0.0, media.width).toDouble(),
          y: media.y + margin,
          width: w,
          height: h,
        ),
      );
      await editor.save(sink);
    } catch (e) {
      _wrap(e);
    } finally {
      await editor?.dispose();
      await sink.close();
    }
    return out;
  }

  @override
  Future<void> saveToCustomLocation(File file) async {
    final target = (await getSaveDirectory()).path;
    final dest = '$target/${file.path.split('/').last}';
    if (dest != file.path) {
      await file.copy(dest);
    }
  }
}
