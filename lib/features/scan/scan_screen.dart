import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/widgets/send_to_tool.dart';
import 'package:scan/presentation/shared/widgets/dialogs/name_prompt_dialog.dart';
import 'package:share_plus/share_plus.dart';

import 'cubit/scan_cubit.dart';
import 'cubit/scan_export_cubit.dart';
import 'cubit/scan_session_cubit.dart';
import 'widgets/scan_page_thumbnail.dart';

/// Scan review flow — strict REPO/DATA <-> BLOC <-> UI.
///
/// UI owns only: SnackBars, Clipboard,
/// open/share/send affordances, and the rename-dialog shell. All capture
/// (ML Kit), session hydrate/persist, and PDF export live in
/// [ScanCubit]/[ScanSessionCubit]/[ScanExportCubit]. This file imports no
/// SharedPreferences, Permission, DocumentScanner, ScannerService, or
/// dart:io — thumbnail File rendering is encapsulated in
/// [ScanPageThumbnail].
class ScanScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ScanSessionCubit()),
        BlocProvider(create: (_) => ScanCubit()),
        BlocProvider(create: (_) => ScanExportCubit()),
      ],
      child: const _ScanView(),
    );
  }
}

/// Capture entry: platform routing lives in [ScanCubit] (Android-only).
/// ML Kit results arrive via the success listener; the session flag guards
/// the interruption notice. UI never touches scanner or platform APIs
/// directly.
Future<void> scanPressed(BuildContext context) async {
  final scanCubit = context.read<ScanCubit>();
  final action = await scanCubit.prepareScan();
  if (!context.mounted) return;
  switch (action) {
    case ScanAction.mlKit:
      // Mark the flight: if the OS kills us while the scanner activity is
      // in front, the surviving flag proves the result never arrived (the
      // finally below cannot run on process death — that is the point).
      // Awaited so the flag is on disk before the scanner takes over.
      final session = context.read<ScanSessionCubit>();
      await session.markScanStarted();
      try {
        await scanCubit.scanWithMlKit();
      } finally {
        await session.clearScanFlag();
      }
    case ScanAction.unsupported:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document scanning is only available on Android.'),
        ),
      );
    case ScanAction.blocked:
      break; // Error card renders from ScanCubit state.
  }
}

/// Rename shell stays in UI — only the name string crosses to the cubit.
/// Export work + errors live in [ScanExportCubit].
Future<void> createPdfPressed(
  BuildContext context,
  List<String> images,
) async {
  if (images.isEmpty) return;
  final now = DateTime.now();
  final defaultName =
      'Scan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  final name = await showNamePrompt(
    context,
    title: 'Name your scan',
    defaultName: defaultName,
    hintText: 'MyScan',
    confirmLabel: 'Create',
  );
  if (name == null || name.isEmpty || !context.mounted) return;
  await context.read<ScanExportCubit>().createPdf(images, name);
}

class _ScanView extends StatefulWidget {
  const new();

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInterrupted());
  }

  /// A surviving in-flight flag means the OS killed us mid-scan and the
  /// result died with the process. The native side stashes the image paths
  /// when the result is delivered to the recreated activity, so first try
  /// to restore the pages; only then fall back to the interrupted notice.
  Future<void> _checkInterrupted() async {
    if (!mounted) return;
    if (!await ScanSessionCubit.consumeInterrupted()) return;
    if (!mounted) return;
    final recovered = await context.read<ScanCubit>().recoverInterruptedScan();
    if (!mounted) return;
    if (recovered.isNotEmpty) {
      context.read<ScanSessionCubit>().appendPages(recovered);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recovered ${recovered.length} page(s) from the interrupted scan '
            '— review below, then create PDF',
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Previous scan was interrupted — the system closed Bento while '
          'scanning. Earlier pages are kept. Tip: lock Bento in recents.',
        ),
        action: SnackBarAction(
          label: 'Scan again',
          onPressed: () {
            if (mounted) unawaited(scanPressed(context));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ML Kit success → append to session + confirm. Cancellation →
        // lightweight notice. Errors render in the error card.
        BlocListener<ScanCubit, ScanState>(
          listenWhen: (prev, next) => prev.status != next.status,
          listener: (context, state) {
            switch (state.status) {
              case ScanStatus.success:
                if (state.pages.isNotEmpty) {
                  context.read<ScanSessionCubit>().appendPages(state.pages);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${state.pages.length} page(s) added — review below, then create PDF',
                      ),
                    ),
                  );
                }
              case ScanStatus.cancelled:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan cancelled')),
                );
              case ScanStatus.idle:
              case ScanStatus.scanning:
              case ScanStatus.error:
                break;
            }
          },
        ),
        // Export success → confirm. Errors render in the error card.
        BlocListener<ScanExportCubit, ScanExportState>(
          listenWhen: (prev, next) => prev.status != next.status,
          listener: (context, state) {
            if (state.status == ScanExportStatus.success &&
                state.pdfPath != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'PDF created: ${state.pdfPath!.split('/').last}',
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: const _ScanBody(),
    );
  }
}

class _ScanBody extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScanSessionCubit>().state;
    final scan = context.watch<ScanCubit>().state;
    final export = context.watch<ScanExportCubit>().state;

    final busy = scan.isScanning;
    final creating = export.isCreating;
    final images = session.images;
    final pdfPath = export.pdfPath;
    // Scan errors and export errors share one card; scan details
    // (ML Kit code/message/stack) drive the Copy-details button.
    final error = scan.error ?? export.error;
    final errorDetails = scan.errorDetails;

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
            title: const Text('Scan'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.document_scanner_rounded,
                                size: 32,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Document scanner',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan pages, review and reorder them below,\nthen name your file and create the PDF.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const ValueKey('scan_button'),
                      onPressed: busy
                          ? null
                          : () async {
                              await scanPressed(context);
                            },
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.document_scanner),
                      label: Text(
                        busy
                            ? 'Scanning…'
                            : (images.isEmpty
                                  ? 'Scan document'
                                  : 'Add more pages'),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorCard(
                        error: error,
                        errorDetails: errorDetails,
                        busy: busy,
                      ),
                    ],
                    if (images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Review pages (${images.length})',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: busy || creating
                                ? null
                                : () => context
                                      .read<ScanSessionCubit>()
                                      .clear(),
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Clear all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: images.length,
                        itemBuilder: (context, i) => RepaintBoundary(
                          child: Stack(
                            children: [
                              ScanPageThumbnail(path: images[i]),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Semantics(
                                  label: 'Remove page ${i + 1}',
                                  button: true,
                                  child: InkWell(
                                    onTap: creating
                                        ? null
                                        : () => context
                                              .read<ScanSessionCubit>()
                                              .removeAt(i),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: scheme.errorContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: creating
                            ? null
                            : () async {
                                await createPdfPressed(context, images);
                              },
                        icon: creating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded),
                        label: Text(
                          creating ? 'Creating…' : 'Name & create PDF',
                        ),
                      ),
                    ],
                    if (pdfPath != null) ...[
                      const SizedBox(height: 12),
                      _PdfResultCard(pdfPath: pdfPath),
                    ],
                    if (pdfPath != null) ...[
                      const SizedBox(height: 12),
                      _PdfActions(pdfPath: pdfPath),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const new({
    required this.error,
    required this.busy,
    this.errorDetails,
  });

  final String error;
  final String? errorDetails;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded, color: scheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (errorDetails != null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(
                        ClipboardData(text: errorDetails!),
                      );
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error details copied — paste them in chat',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy details'),
                  ),
                OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          await scanPressed(context);
                        },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfResultCard extends StatelessWidget {
  const new({required this.pdfPath});

  final String pdfPath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf_rounded,
          color: scheme.onPrimaryContainer,
        ),
        title: Text(
          pdfPath.split('/').last,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          pdfPath,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'Open PDF',
              onPressed: () => openDoc(context, pdfPath),
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              tooltip: 'Send to tool',
              onPressed: () => SendToToolSheet.show(context, pdfPath),
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share',
              onPressed: () => SharePlus.instance.share(
                ShareParams(files: [XFile(pdfPath)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfActions extends StatelessWidget {
  const new({required this.pdfPath});

  final String pdfPath;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => openDoc(context, pdfPath),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Open'),
        ),
        OutlinedButton.icon(
          onPressed: () => SharePlus.instance.share(
            ShareParams(files: [XFile(pdfPath)]),
          ),
          icon: const Icon(Icons.share_rounded),
          label: const Text('Share'),
        ),
        OutlinedButton.icon(
          onPressed: () => SendToToolSheet.show(context, pdfPath),
          icon: const Icon(Icons.send_outlined),
          label: const Text('Send to tool'),
        ),
      ],
    );
  }
}
