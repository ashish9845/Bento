import 'dart:io';
import 'dart:typed_data';

import 'package:pdf_manipulator/pdf_manipulator.dart';
import '../datasources/pdf_engine_data_source.dart';
import 'tools_repository.dart';
import '../../../core/errors/failures.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  final PdfEngineDataSource engine;
  ToolsRepositoryImpl(this.engine);

  @override
  Future<int> pageCount(File input) async {
    try {
      return await engine.pageCount(input);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> mergePdfs(List<File> inputs) async {
    try {
      return await engine.merge(inputs);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<File>> splitPdf(File input, String rangesSpec) async {
    try {
      return await engine.split(input, rangesSpec);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> extractPages(File input, List<int> pages) async {
    try {
      return await engine.extract(input, pages);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> organizePdf(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
  }) async {
    try {
      return await engine.organize(input, delete: delete, rotations: rotations, order: order);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> compressPdf(File input, PdfImagePolicy policy) async {
    try {
      return await engine.compress(input, policy);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> imageToPdf(List<File> images, {String? outputName}) async {
    try {
      return await engine.imagesToPdf(images, outputName: outputName);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<File>> renderPages(File input) async {
    try {
      return await engine.renderPages(input);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
  }) async {
    try {
      return await engine.signPdf(
        input,
        signaturePng: signaturePng,
        page: page,
        widthPts: widthPts,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveFile(File file) async {
    try {
      await engine.saveToCustomLocation(file);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
