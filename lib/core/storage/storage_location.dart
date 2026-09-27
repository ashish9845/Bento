import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'storage_location';

/// Central save-location logic.
///
/// Default is the shared internal-storage Documents folder:
///   Android: /storage/emulated/0/Documents/Bento (visible in file managers)
///   iOS/other: app documents (no shared Documents concept)
///
/// A custom directory chosen in Settings overrides the default.
Future<Directory> getDefaultSaveDirectory() async {
  if (Platform.isAndroid) {
    try {
      // getExternalStorageDirectory() -> /storage/emulated/0/Android/data/<pkg>/files
      // Walk up to the shared-storage root, then into Documents/Bento.
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final idx = ext.path.indexOf('/Android/data');
        if (idx != -1) {
          final docs = Directory(
            '${ext.path.substring(0, idx)}/Documents/Bento',
          );
          await docs.create(recursive: true);
          return docs;
        }
      }
    } catch (_) {
      // Fall through to app documents.
    }
  }
  return getApplicationDocumentsDirectory();
}

/// Effective save directory: custom Settings pick if set and exists, else default.
Future<Directory> getSaveDirectory() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_key);
    if (custom != null) {
      final dir = Directory(custom);
      if (await dir.exists()) return dir;
    }
  } catch (_) {}
  return getDefaultSaveDirectory();
}

/// Best-effort storage permission for writing to shared Documents (Android only).
/// Returns true if shared-storage writes are (likely) allowed.
Future<bool> ensureStoragePermission() async {
  if (!Platform.isAndroid) return true;
  try {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    return await Permission.manageExternalStorage.request().isGranted;
  } catch (_) {
    return false;
  }
}

final storageLocationProvider =
    StateNotifierProvider<StorageLocationNotifier, String?>((ref) {
      return StorageLocationNotifier();
    });

class StorageLocationNotifier extends StateNotifier<String?> {
  StorageLocationNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setLocation(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, path);
    }
    state = path;
  }

  Future<void> clear() => setLocation(null);
}
