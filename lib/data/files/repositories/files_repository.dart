import 'dart:io';

import '../models/bento_file.dart';

abstract class FilesRepository {
  Future<List<BentoFile>> fetchRecentFiles();
  Future<void> deleteFile(String path);

  /// Copies picked files into the save directory so they show up in Recents.
  /// Returns the saved files. Skips files that are already inside the target.
  Future<List<BentoFile>> importFiles(List<File> picked);
}
