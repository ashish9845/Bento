import 'package:flutter/material.dart';

/// Name-your-file prompt used before every tool/scan/export action.
///
/// A full StatefulWidget (not an inline builder closure) so the
/// [TextEditingController] owns a real lifecycle: created with the dialog
/// state, disposed in [State.dispose] after the pop transition unmounts the
/// field. Disposing a dialog-owned controller right after `showDialog`
/// returns crashes with "TextEditingController was used after being
/// disposed" — the field is still mounted while popping.
class NamePromptDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.defaultName,
    this.labelText = 'File name',
    this.hintText = 'MyDocument',
    this.suffixText = '.pdf',
    this.confirmLabel = 'Continue',
    super.key,
  });

  final String title;
  final String defaultName;
  final String labelText;
  final String hintText;
  final String suffixText;
  final String confirmLabel;

  @override
  State<NamePromptDialog> createState() => _NamePromptDialogState();
}

class _NamePromptDialogState extends State<NamePromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.defaultName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          suffixText: widget.suffixText,
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Shows [NamePromptDialog]; returns the trimmed name, or null on
/// cancel/empty.
Future<String?> showNamePrompt(
  BuildContext context, {
  required String title,
  required String defaultName,
  String hintText = 'MyDocument',
  String confirmLabel = 'Continue',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => NamePromptDialog(
      title: title,
      defaultName: defaultName,
      hintText: hintText,
      confirmLabel: confirmLabel,
    ),
  );
}
