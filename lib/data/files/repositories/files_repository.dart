import '../models/bento_file.dart';

abstract class FilesRepository {
  Future<List<BentoFile>> fetchRecentFiles();
  Future<void> deleteFile(String path);
}
