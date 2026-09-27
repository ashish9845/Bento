import 'package:flutter/material.dart';

import '../../../data/files/models/bento_file.dart';

/// Recents feed rows (icon tile, name, date · size). The section header lives
/// in the page so it stays visible during loading/error states.
/// Pure display — taps are owned by the page.
class HomeRecents extends StatelessWidget {
  const new({required this.files, required this.onOpen, super.key});

  final List<BentoFile> files;
  final void Function(BentoFile file) onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 32,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent files yet',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan, import, or convert something to see it here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < files.length; i++) ...[
                  _RecentRow(
                    key: ValueKey('home_recent_${files[i].name}'),
                    file: files[i],
                    onTap: () => onOpen(files[i]),
                  ),
                  if (i != files.length - 1)
                    const Divider(height: 1, indent: 62),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const new({required this.file, required this.onTap, super.key});

  final BentoFile file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kb = (file.size / 1024).toStringAsFixed(1);
    final date = file.modified.toLocal().toString().split('.').first;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 46,
        height: 56,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Icon(
          Icons.picture_as_pdf_rounded,
          size: 22,
          color: scheme.primary,
        ),
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '$date · $kb KB',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: scheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
