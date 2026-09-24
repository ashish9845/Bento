import '../datasources/files_local_data_source.dart';
import '../models/bento_file.dart';
import 'files_repository.dart';
import '../../../core/errors/failures.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesLocalDataSource local;
  FilesRepositoryImpl(this.local);

  @override
  Future<List<BentoFile>> fetchRecentFiles() async {
    try {
      return await local.getRecentFiles();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      await local.deleteFile(path);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
