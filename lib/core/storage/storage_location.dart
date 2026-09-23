import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'storage_location';

final storageLocationProvider = StateNotifierProvider<StorageLocationNotifier, String?>((ref) {
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
