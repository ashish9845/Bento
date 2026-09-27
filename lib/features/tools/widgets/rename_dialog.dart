import 'package:flutter/material.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';

/// Timestamped default file name, e.g. `Split_20250925_2130`.
String defaultOutputName(String prefix) {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${prefix}_${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
}

/// Asks for a file name before a tool runs. Returns null when cancelled.
/// The `.pdf` suffix is added automatically — never type it.
Future<String?> askOutputName(
  BuildContext context, {
  required String defaultName,
  String title = 'Name your PDF',
  String hint = 'MyDocument',
}) async {
  final controller = TextEditingController(text: defaultName);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'File name',
          hintText: hint,
          suffixText: '.pdf',
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Continue')),
      ],
    ),
  );
  if (name == null || name.isEmpty) return null;
  return name;
}

/// Asks for a file name, stores it on the controller, and runs the tool.
/// Used by every tool screen so naming happens before the action runs.
Future<void> runWithRename({
  required BuildContext context,
  required ToolController ctrl,
  required String defaultName,
  String title = 'Name your PDF',
}) async {
  final name = await askOutputName(context, defaultName: defaultName, title: title);
  if (name == null || name.isEmpty || !context.mounted) return;
  ctrl.outputName = name;
  await ctrl.run();
}
