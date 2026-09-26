import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/storage_location.dart';
import '../models/bento_file.dart';

abstract class FilesLocalDataSource {
  Future<List<BentoFile>> getRecentFiles({int limit = 30});
  Future<void> deleteFile(String path);
  Future<List<BentoFile>> importFiles(List<File> picked);
}

class FilesLocalDataSourceImpl implements FilesLocalDataSource {
  @override
  Future<List<BentoFile>> getRecentFiles({int limit = 30}) async {
    final docs = await getApplicationDocumentsDirectory();
    final tmp = await getTemporaryDirectory();
    final defaultDir = await getDefaultSaveDirectory();
    final dirs = <Directory>[docs, tmp, defaultDir];
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString('storage_location');
      if (custom != null) {
        final c = Directory(custom);
        if (await c.exists()) dirs.add(c);
      }
    } catch (_) {}
    // Deduplicate by file name — same PDF saved to both tmp and docs should appear once
    final byName = <String, BentoFile>{};
    for (final dir in dirs) {
      if (!await dir.exists()) continue;
      await for (final e in dir.list()) {
        if (e is File && e.path.toLowerCase().endsWith('.pdf')) {
          try {
            final stat = await e.stat();
            final name = e.path.split('/').last;
            final existing = byName[name];
            final candidate = BentoFile(path: e.path, name: name, size: stat.size, modified: stat.modified);
            // Prefer docs/custom over tmp, and newer modified
            if (existing == null) {
              byName[name] = candidate;
            } else {
              final isExistingTmp = existing.path.contains('/cache/') || existing.path.contains('/tmp/');
              final isCandidateTmp = candidate.path.contains('/cache/') || candidate.path.contains('/tmp/');
              if (isExistingTmp && !isCandidateTmp) {
                byName[name] = candidate;
              } else if (candidate.modified.isAfter(existing.modified)) {
                byName[name] = candidate;
              }
            }
          } catch (_) {}
        }
      }
    }
    final out = byName.values.toList()..sort((a, b) => b.modified.compareTo(a.modified));
    return out.take(limit).toList();
  }

  @override
  Future<void> deleteFile(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<List<BentoFile>> importFiles(List<File> picked) async {
    final target = await getSaveDirectory();
    final saved = <BentoFile>[];
    for (final src in picked) {
      if (!await src.exists()) continue;
      final name = src.path.split('/').last;
      var dest = File('${target.path}/$name');
      if (dest.path == src.path) {
        // Already inside the save directory — adopt as-is.
      } else {
        var counter = 1;
        while (await dest.exists()) {
          final stem = name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
          dest = File('${target.path}/${stem}_$counter.pdf');
          counter++;
        }
        await src.copy(dest.path);
      }
      try {
        final stat = await dest.stat();
        saved.add(BentoFile(path: dest.path, name: dest.path.split('/').last, size: stat.size, modified: stat.modified));
      } catch (_) {}
    }
    if (saved.isEmpty) throw Exception('Nothing could be imported');
    return saved;
  }
}
