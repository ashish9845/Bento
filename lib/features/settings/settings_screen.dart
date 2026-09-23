import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan/core/storage/storage_location.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            title: const Text('Settings'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.surface, scheme.secondaryContainer.withValues(alpha: 0.3)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                _SectionHeader(icon: Icons.palette_rounded, title: 'Appearance'),
                RepaintBoundary(
                  child: Card(
                    child: SwitchListTile(
                      title: const Text('Dark theme'),
                      subtitle: const Text('Follows system — warm bento palette adapts'),
                      value: Theme.of(context).brightness == Brightness.dark,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.dark_mode_rounded, size: 20, color: scheme.onPrimaryContainer),
                      ),
                      onChanged: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Theme follows system for v1 — change device theme')),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(icon: Icons.storage_rounded, title: 'Storage'),
                RepaintBoundary(
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.folder_rounded, size: 20, color: scheme.onSecondaryContainer),
                      ),
                      title: const Text('Save location'),
                      subtitle: Consumer(builder: (context, ref, _) {
                        final custom = ref.watch(storageLocationProvider);
                        if (custom != null) return Text(custom, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall);
                        return FutureBuilder(
                          future: getApplicationDocumentsDirectory(),
                          builder: (context, snap) => Text(snap.data?.path ?? 'App documents', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                        );
                      }),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Consumer(builder: (context, ref, _) {
                          final custom = ref.watch(storageLocationProvider);
                          if (custom == null) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.restart_alt_rounded, size: 20),
                            tooltip: 'Reset to default',
                            onPressed: () async {
                              await ref.read(storageLocationProvider.notifier).clear();
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset to app documents')));
                            },
                          );
                        }),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ]),
                      onTap: () async {
                        final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Pick storage location');
                        if (dir != null) {
                          await ref.read(storageLocationProvider.notifier).setLocation(dir);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(dir == null ? 'No selection' : 'Storage set to $dir — new PDFs will save there')),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(icon: Icons.info_rounded, title: 'About'),
                _AboutCard(),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy',
                  subtitle: 'On-device only — no network',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Privacy'),
                      content: const Text('All PDF processing and scanning happens on-device. No file is uploaded. WASM modules and OCR data are bundled at install. Engine runs on 127.0.0.1 with COOP/COEP for SharedArrayBuffer.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                    ),
                  ),
                ),
                _InfoTile(
                  icon: Icons.code_rounded,
                  title: 'Engine',
                  subtitle: 'assets/engine/ — Vite headless bundle',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Engine: 56 MB apparent (7 tools, no Tesseract) — see docs/engine-mapping.md')));
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text('Bento • AGPL-3.0 • v1.0.0+1', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
      ]),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Bento',
              applicationVersion: '1.0.0+1',
              applicationLegalese: 'AGPL-3.0. Bundled: PyMuPDF, Ghostscript, CoherentPDF (AGPL), BentoPDF engine, Tesseract (Apache 2.0 for v1.1).',
              children: [
                const SizedBox(height: 12),
                Text('This app ships AGPL-3.0. Full source including UI is published with every build. Offline-only: no CDN, no download-on-first-use.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.lunch_dining_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('About & Licenses', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    Text('AGPL-3.0 — full source published', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: scheme.secondaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: scheme.onSecondaryContainer),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
