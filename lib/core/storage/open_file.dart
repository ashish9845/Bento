import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'storage_location.dart';

/// Opens a file or folder with the system viewer, with visible feedback.
///
/// `OpenFilex.open` fails silently from the user's perspective (it only
/// returns a result object), so every Open button in the app goes through
/// here. A `permissionDenied` result triggers a storage-permission request
/// and retry; if access is still blocked, the user gets guidance to Settings
/// instead of a dead button.
Future<void> openDoc(BuildContext context, String path) async {
  final name = path.split('/').last;
  final displayName = name.isEmpty ? 'folder' : name;
  try {
    var result = await OpenFilex.open(path);
    if (result.type == ResultType.done) return;
    if (result.type == ResultType.permissionDenied) {
      final granted = await ensureStoragePermission();
      if (granted) {
        result = await OpenFilex.open(path);
        if (result.type == ResultType.done) return;
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Storage permission is needed to open files. Allow "All files access" in Settings.',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
      return;
    }
    final msg = switch (result.type) {
      ResultType.noAppToOpen => 'No app found to open $displayName',
      ResultType.fileNotFound => 'File not found: $displayName',
      _ => 'Could not open $displayName (${result.message})',
    };
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'Share instead',
          onPressed: () =>
              SharePlus.instance.share(ShareParams(files: [XFile(path)])),
        ),
      ),
    );
  } on Exception catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $displayName: $e')));
  }
}
