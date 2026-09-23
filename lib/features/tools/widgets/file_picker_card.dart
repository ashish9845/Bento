import 'dart:io';

import 'package:flutter/material.dart';

class FilePickerCard extends StatelessWidget {
  const FilePickerCard({
    required this.files,
    required this.onPick,
    required this.onClear,
    super.key,
    this.allowMultiple = false,
    this.allowedExtensions,
    this.label = 'PDF files',
  });

  final List<File> files;
  final Future<void> Function() onPick;
  final void Function() onClear;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: files.isEmpty ? scheme.outlineVariant.withValues(alpha: 0.6) : scheme.primary.withValues(alpha: 0.25), width: files.isEmpty ? 1.2 : 1.6),
          boxShadow: files.isEmpty ? [] : [BoxShadow(color: scheme.primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.folder_open_rounded, size: 20, color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      if (files.isNotEmpty)
                        Text('${files.length} selected • tap to add more',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ]),
                  ),
                  if (files.isNotEmpty)
                    Semantics(
                      label: 'Clear selected files',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: onClear,
                        tooltip: 'Clear',
                        style: IconButton.styleFrom(backgroundColor: scheme.errorContainer, foregroundColor: scheme.onErrorContainer, minimumSize: const Size(36, 36)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (files.isEmpty)
                Semantics(
                  label: 'Pick file',
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      // micro-interaction scale via InkWell splash is enough; avoid rebuilding
                      await onPick();
                    },
                    child: Container(
                      height: 92,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5), style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 28, color: scheme.primary),
                          const SizedBox(height: 6),
                          Text('Tap to pick ${allowedExtensions?.join(', ') ?? 'files'}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(allowMultiple ? 'Multiple allowed' : 'Single file',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        ]),
                      ),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // file list with builder for performance
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: files.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final f = files[i];
                        return Container(
                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Icon(allowedExtensions?.contains('pdf') ?? true ? Icons.picture_as_pdf_rounded : Icons.image_rounded, size: 18, color: scheme.primary),
                            ),
                            title: Text(f.path.split('/').last, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: FutureBuilder<int>(
                              future: f.length().catchError((_) => 0),
                              builder: (context, snap) {
                                if (!snap.hasData) return const SizedBox.shrink();
                                final kb = (snap.data! / 1024).toStringAsFixed(1);
                                return Text('$kb KB', style: Theme.of(context).textTheme.bodySmall);
                              },
                            ),
                            trailing: null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async => onPick(),
                      icon: Icon(allowMultiple ? Icons.add_rounded : Icons.swap_horiz_rounded, size: 18),
                      label: Text(allowMultiple ? 'Add more' : 'Replace file'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
