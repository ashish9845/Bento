import 'dart:io';

import 'package:flutter/material.dart';

/// Single reviewed page thumbnail.
///
/// Lives in its own widget so `scan_screen.dart` never imports `dart:io`:
/// File-backed image rendering stays encapsulated here (presentation-only —
/// no existence checks, reads, or writes; those belong in cubits).
class ScanPageThumbnail extends StatelessWidget {
  const new({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
