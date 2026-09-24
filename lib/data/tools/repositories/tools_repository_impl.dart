import 'dart:io';
import '../datasources/tools_local_data_source.dart';
import 'tools_repository.dart';
import '../../../core/errors/failures.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  final ToolsLocalDataSource local;
  ToolsRepositoryImpl(this.local);

  @override
  Future<File> mergePdfs(List<File> inputs) async {
    try {
      return await local.mergePdfs(inputs);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<File> imageToPdf(List<File> images, {String? outputName}) async {
    try {
      return await local.imageToPdf(images, outputName: outputName);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveFile(File file) async {
    try {
      await local.saveToCustomLocation(file);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
