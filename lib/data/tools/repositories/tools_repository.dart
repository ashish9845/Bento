import 'dart:io';

abstract class ToolsRepository {
  Future<File> mergePdfs(List<File> inputs);
  Future<File> imageToPdf(List<File> images, {String? outputName});
  Future<void> saveFile(File file);
}
