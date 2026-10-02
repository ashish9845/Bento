import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/error_reporting.dart';

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
    } on Exception catch (e, s) {
      ErrorReporting.log(e, s, context: 'storage');
      // Fall through to app documents.
    }
  }
  return await getApplicationDocumentsDirectory();
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
  } on Exception catch (e, s) {
    ErrorReporting.log(e, s, context: 'storage');
  }
  return await getDefaultSaveDirectory();
}

/// Best-effort storage permission for writing to shared Documents (Android only).
/// Returns true if shared-storage writes are (likely) allowed.
Future<bool> ensureStoragePermission() async {
  if (!Platform.isAndroid) return true;
  try {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    return await Permission.manageExternalStorage.request().isGranted;
  } on Exception catch (e, s) {
    ErrorReporting.log(e, s, context: 'storage');
    return false;
  }
}

/// Resolved save-location state. The cubit resolves the platform default
/// once at startup; the UI only reads [effectivePath]/[displayPath] and
/// never touches path_provider / SharedPreferences / dart:io itself.
class StorageLocationState {
  const new({this.customPath, this.defaultPath, this.message});

  /// Custom directory picked in Settings (null = use the default).
  final String? customPath;

  /// Platform default, resolved once in the cubit (null until ready).
  final String? defaultPath;

  /// One-shot UI message (snackbar). Cleared via [StorageLocationCubit.consumeMessage].
  final String? message;

  /// Directory actually used for saves: custom override, else default.
  String? get effectivePath => customPath ?? defaultPath;

  /// Display fallback while the default is still resolving.
  String get displayPath => effectivePath ?? 'Documents/Bento';

  bool get isReady => defaultPath != null;
  bool get hasCustom => customPath != null;

  StorageLocationState copyWith({
    String? customPath,
    String? defaultPath,
    String? message,
    bool clearMessage = false,
  }) => StorageLocationState(
    customPath: customPath ?? this.customPath,
    defaultPath: defaultPath ?? this.defaultPath,
    message: clearMessage ? null : (message ?? this.message),
  );

  StorageLocationState withoutCustom() =>
      StorageLocationState(defaultPath: defaultPath, message: message);
}

/// Selected save location override (custom directory path, or null for the
/// default). Persisted in SharedPreferences.
///
/// Owns ALL storage data access: default resolution, persistence,
/// permission request, and the directory picker. UI layers only call
/// [pickAndSet]/[setLocation]/[clear] and render [StorageLocationState].
class StorageLocationCubit extends Cubit<StorageLocationState> {
  new() : super(const StorageLocationState()) {
    unawaited(_init());
  }

  /// Resolve the platform default once + restore the persisted override.
  Future<void> _init() async {
    String? def;
    try {
      def = (await getDefaultSaveDirectory()).path;
    } on Exception catch (e, s) {
      addError(e, s);
    }
    if (isClosed) return;
    String? custom;
    try {
      custom = (await SharedPreferences.getInstance()).getString(_key);
    } on Exception catch (e, s) {
      addError(e, s);
    }
    if (isClosed) return;
    emit(state.copyWith(customPath: custom, defaultPath: def));
  }

  Future<void> setLocation(String? path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, path);
      }
    } on Exception catch (e, s) {
      addError(e, s);
    }
    if (isClosed) return;
    if (path == null) {
      emit(
        state.withoutCustom().copyWith(
          message: 'Reset to ${state.defaultPath ?? 'default'}',
        ),
      );
    } else {
      emit(
        state.copyWith(
          customPath: path,
          message: 'Storage set to $path — new PDFs will save there',
        ),
      );
    }
  }

  /// Permission + directory picker + persist. Emits a
  /// [StorageLocationState.message] for the UI listener to show as a
  /// snackbar (including 'No selection').
  Future<void> pickAndSet() async {
    // Best-effort: allow writes to shared storage before picking.
    await ensureStoragePermission();
    final dir = await FilePicker.getDirectoryPath(
      dialogTitle: 'Pick storage location',
    );
    if (isClosed) return;
    if (dir == null) {
      emit(state.copyWith(message: 'No selection'));
      return;
    }
    await setLocation(dir);
  }

  Future<void> clear() => setLocation(null);

  void consumeMessage() {
    if (state.message != null) emit(state.copyWith(clearMessage: true));
  }
}
