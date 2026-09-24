import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

/// Opens a file or folder with the system viewer, with visible feedback.
///
/// `OpenFilex.open` fails silently from the user's perspective (it only
/// returns a result object), so every Open button in the app goes through
/// here: failures show what happened and offer Share as a fallback.
Future<void> openDoc(BuildContext context, String path) async {
  final name = path.split('/').last;
  final displayName = name.isEmpty ? 'folder' : name;
  try {
    final result = await OpenFilex.open(path);
    if (result.type == ResultType.done) return;
    final msg = switch (result.type) {
      ResultType.noAppToOpen => 'No app found to open $displayName',
      ResultType.fileNotFound => 'File not found: $displayName',
      ResultType.permissionDenied => 'Storage permission denied — cannot open $displayName',
      _ => 'Could not open $displayName (${result.message})',
    };
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'Share instead',
          onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(path)])),
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $displayName: $e')),
    );
  }
}
