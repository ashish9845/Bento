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
  Future<File> mergePdfs(List<File> inputs, {String? outputName}) async {
    try {
      return await engine.merge(inputs, outputName: outputName);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<File>> splitPdf(
    File input,
    String rangesSpec, {
    String? baseName,
  }) async {
    try {
      return await engine.split(input, rangesSpec, baseName: baseName);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> extractPages(
    File input,
    List<int> pages, {
    String? outputName,
  }) async {
    try {
      return await engine.extract(input, pages, outputName: outputName);
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
    String? outputName,
  }) async {
    try {
      return await engine.organize(
        input,
        delete: delete,
        rotations: rotations,
        order: order,
        outputName: outputName,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> compressPdf(
    File input,
    PdfImagePolicy policy, {
    String? outputName,
  }) async {
    try {
      return await engine.compress(input, policy, outputName: outputName);
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
  Future<List<File>> renderPages(File input, {String? outputName}) async {
    try {
      return await engine.renderPages(input, outputName: outputName);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<List<File>> renderThumbnails(File input) async {
    try {
      return await engine.renderThumbnails(input);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> protectPdf(
    File input, {
    required String userPassword,
    String? ownerPassword,
    String? outputName,
  }) async {
    try {
      return await engine.protectPdf(
        input,
        userPassword: userPassword,
        ownerPassword: ownerPassword,
        outputName: outputName,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> unlockPdf(
    File input, {
    required String password,
    String? outputName,
  }) async {
    try {
      return await engine.unlockPdf(
        input,
        password: password,
        outputName: outputName,
      );
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
    String? outputName,
  }) async {
    try {
      return await engine.signPdf(
        input,
        signaturePng: signaturePng,
        page: page,
        widthPts: widthPts,
        outputName: outputName,
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
