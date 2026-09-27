import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/storage_location.dart';

import 'widgets/theme_settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        scheme.secondaryContainer.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lunch_dining_rounded,
                          color: scheme.onPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bento',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    color: scheme.onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'v1.0.0 • AGPL-3.0',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: scheme.onPrimaryContainer.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                _MiniBadge(
                                  icon: Icons.offline_bolt_rounded,
                                  label: 'Offline',
                                ),
                                SizedBox(width: 6),
                                _MiniBadge(
                                  icon: Icons.picture_as_pdf_rounded,
                                  label: '10 tools',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList.list(
              children: [
                const ThemeSettingsCard(),
                const SizedBox(height: 16),
                _SectionHeader(icon: Icons.storage_rounded, title: 'Storage'),
                RepaintBoundary(
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.folder_rounded,
                          size: 20,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                      title: const Text('Save location'),
                      subtitle: BlocBuilder<StorageLocationCubit, String?>(
                        builder: (context, custom) {
                          if (custom != null) {
                            return Text(
                              custom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return FutureBuilder(
                            future: getDefaultSaveDirectory(),
                            builder: (context, snap) => Text(
                              snap.data?.path ?? 'Documents/Bento',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<StorageLocationCubit, String?>(
                            builder: (context, custom) {
                              if (custom == null) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: const Icon(
                                  Icons.restart_alt_rounded,
                                  size: 20,
                                ),
                                tooltip: 'Reset to default',
                                onPressed: () async {
                                  await context
                                      .read<StorageLocationCubit>()
                                      .clear();
                                  final def = await getDefaultSaveDirectory();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Reset to ${def.path}'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                      onTap: () async {
                        final storage = context.read<StorageLocationCubit>();
                        // Best-effort: allow writes to shared storage before picking.
                        await ensureStoragePermission();
                        final dir = await FilePicker.getDirectoryPath(
                          dialogTitle: 'Pick storage location',
                        );
                        if (dir != null) {
                          await storage.setLocation(dir);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                dir == null
                                    ? 'No selection'
                                    : 'Storage set to $dir — new PDFs will save there',
                              ),
                            ),
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
                      content: const Text(
                        'All PDF processing and scanning happens on-device. No file is uploaded. The native engine (pdf_manipulator, MIT) runs via FFI off the main thread — no WebView, no network.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
                _InfoTile(
                  icon: Icons.code_rounded,
                  title: 'Engine',
                  subtitle: 'Native FFI engine (pdf_manipulator, MIT)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Native Rust engine over FFI — merge, split, organize, compress, render, all on-device',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Bento • AGPL-3.0 • v1.0.0+1',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const new({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.primaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: scheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const new({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
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
              applicationLegalese: 'AGPL-3.0. Engine: pdf_manipulator (MIT). Scanner: ML Kit (Android) / OpenScan (iOS, BSD-3-Clause).',
              children: [
                const SizedBox(height: 12),
                Text(
                  'This app ships AGPL-3.0. Full source including UI is published with every build. Offline-only: no CDN, no download-on-first-use.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Document scanner: Google ML Kit on Android; OpenScan pipeline by Vijay T S and Vikram H (BSD-3-Clause, see third_party/openscan/LICENSE) on iOS.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lunch_dining_rounded,
                    color: scheme.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About & Licenses',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'AGPL-3.0 — full source published',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
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
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: scheme.onSecondaryContainer),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
