import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet listing target tools for a file.
///
/// Takes a plain path string (no dart:io in UI data flow); navigation only.
class SendToToolSheet extends StatelessWidget {
  const new({required this.filePath, super.key});
  final String filePath;

  static Future<void> show(BuildContext context, String filePath) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SendToToolSheet(filePath: filePath),
      );

  @override
  Widget build(BuildContext context) {
    const tools = [
      ('Compress PDF', Icons.compress, '/tools/compress'),
      ('Merge PDFs', Icons.merge, '/tools/merge'),
      ('Sign PDF', Icons.draw_outlined, '/tools/sign'),
      ('Organize Pages', Icons.view_carousel_outlined, '/tools/organize'),
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text('Send to tool', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            filePath.split('/').last,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(),
          for (final t in tools)
            ListTile(
              leading: Icon(t.$2),
              title: Text(t.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                context.go(t.$3);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Send ${filePath.split('/').last} → ${t.$1} (pick file again in target tool for v1)',
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
