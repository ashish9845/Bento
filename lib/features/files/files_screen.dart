import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/core/storage/storage_location.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:share_plus/share_plus.dart';

Future<List<File>> _loadRecentFiles() async {
  final docs = await getApplicationDocumentsDirectory();
  final tmp = await getTemporaryDirectory();
  final defaultDir = await getDefaultSaveDirectory();
  final files = <File>[];
  final dirs = <Directory>[docs, tmp, defaultDir];
  try {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString('storage_location');
    if (custom != null) {
      final c = Directory(custom);
      if (await c.exists()) dirs.add(c);
    }
  } on Exception catch (_) {}
  for (final dir in dirs) {
    if (!await dir.exists()) continue;
    await for (final e in dir.list()) {
      if (e is File && e.path.toLowerCase().endsWith('.pdf')) files.add(e);
    }
  }
  files.sort((a, b) {
    try {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    } on Exception catch (_) {
      return 0;
    }
  });
  return files.take(30).toList();
}

class FilesScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late Future<List<File>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _recentFuture = _loadRecentFiles();
  }

  void _refresh() {
    setState(() => _recentFuture = _loadRecentFiles());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('Files'),
            actions: [
              IconButton.filledTonal(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: _refresh,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
            ],
          ),
          FutureBuilder<List<File>>(
            future: _recentFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snap.error}')),
                );
              }
              final files = snap.data ?? const <File>[];
              if (files.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.folder_open_rounded,
                              size: 40,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No PDFs yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your merged, compressed, scanned and converted PDFs will appear here.\nPull to refresh.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                sliver: SliverList.separated(
                  itemCount: files.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final f = files[i];
                    String kb = '—';
                    String date = '';
                    try {
                      final stat = f.statSync();
                      kb = (stat.size / 1024).toStringAsFixed(1);
                      date = stat.modified
                          .toLocal()
                          .toString()
                          .split('.')
                          .first;
                    } on Exception catch (_) {
                      // Stat can fail on stale entries — keep placeholders.
                    }
                    // staggered entrance
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 280 + i * 30),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 8 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: RepaintBoundary(
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 20,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              f.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '$kb KB • $date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 16,
                                  ),
                                  onPressed: () =>
                                      SendToToolSheet.show(context, f),
                                  tooltip: 'Send to tool',
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(36, 36),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(
                                    Icons.share_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () => SharePlus.instance.share(
                                    ShareParams(files: [XFile(f.path)]),
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: scheme.primary,
                                    foregroundColor: scheme.onPrimary,
                                    minimumSize: const Size(36, 36),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => openDoc(context, f.path),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
