import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session images for the Scan review flow.
///
/// DATA-layer owner of the pending-images key: hydrate/persist via
/// SharedPreferences live here (mirrors the ToolCubit hydrate/persist
/// pattern). UI only reads the session images via BlocBuilder and
/// dispatches `appendPages`/`removeAt`/`clear` — it never touches
/// SharedPreferences or File existence checks directly.
class ScanSessionState {
  const new({this.images = const []});

  final List<String> images;

  ScanSessionState copyWith({List<String>? images}) =>
      ScanSessionState(images: images ?? this.images);
}

class ScanSessionCubit extends Cubit<ScanSessionState> {
  new() : super(const ScanSessionState()) {
    unawaited(hydrate());
  }

  /// Review pages mirrored here so they survive Android killing the app
  /// while the scanner activity is in front.
  static const pendingImagesKey = 'scan_pending_images';

  /// Set while the external ML Kit scanner activity owns the foreground.
  /// The OS may kill our process there (aggressive on MIUI); the flag is
  /// cleared only when the scanner returns, so a surviving flag on next
  /// launch means the result died with the process — see
  /// [consumeInterrupted]. Never holds pages, just the in-flight marker.
  static const scanInFlightKey = 'scan_in_flight';

  static const maxPages = 30;

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = prefs.getStringList(pendingImagesKey) ?? const [];
      final existing = paths
          .where((p) => p.isNotEmpty && File(p).existsSync())
          .take(maxPages)
          .toList();
      if (isClosed) return;
      if (existing.isNotEmpty) {
        emit(state.copyWith(images: existing));
      } else if (existing.length != paths.length) {
        await prefs.setStringList(pendingImagesKey, existing);
      }
    } on Exception catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        pendingImagesKey,
        state.images.take(maxPages).toList(),
      );
    } on Exception catch (_) {}
  }

  void appendPages(List<String> pages) {
    if (pages.isEmpty || isClosed) return;
    emit(state.copyWith(images: [...state.images, ...pages]));
    unawaited(_persist());
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.images.length || isClosed) return;
    emit(
      state.copyWith(images: [...state.images]..removeAt(index)),
    );
    unawaited(_persist());
  }

  void clear() {
    if (state.images.isEmpty || isClosed) return;
    emit(state.copyWith(images: []));
    unawaited(_persist());
  }

  Future<void> _writeFlag(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(scanInFlightKey, value);
    } on Exception catch (_) {}
  }

  /// Call immediately before handing the foreground to the scanner. Awaited
  /// by the UI so the flag is on disk before the scanner activity can take
  /// over (a lost write would hide a real interruption).
  Future<void> markScanStarted() => _writeFlag(true);

  /// Call once the scanner returns (success, cancel, or error). Never runs
  /// when the process died mid-scan — that is exactly what makes the
  /// surviving flag meaningful.
  Future<void> clearScanFlag() => _writeFlag(false);

  /// True once when a previous scan died mid-flight. Consumes the flag, so
  /// the interruption is reported exactly once.
  static Future<bool> consumeInterrupted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(scanInFlightKey) ?? false) {
        await prefs.setBool(scanInFlightKey, false);
        return true;
      }
    } on Exception catch (_) {}
    return false;
  }
}
