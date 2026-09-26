import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

final organizeControllerProvider =
    StateNotifierProvider<ToolController, ToolState>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  return ToolController(persistenceKey: 'organize', processFn: (inputs, ctrl) async {
    final count = await repo.pageCount(inputs.first);
    final natural = [for (var i = 0; i < count; i++) i];
    final order = ref.read(organizeOrderProvider) ?? natural;
    if (order.isEmpty) throw Exception('No pages left — tap Reset to restore them');
    final rotations = ref.read(organizeRotationsProvider);
    ctrl.setProgress(null, 'Applying changes to ${order.length} pages…');
    final out = await repo.organizePdf(inputs.first,
        order: order, rotations: rotations, outputName: ctrl.outputName);
    return [out];
  });
});

/// Working page order as original 0-based indices. Duplicates allowed,
/// deletions are items removed from the list. `null` = untouched natural order.
final organizeOrderProvider = StateProvider<List<int>?>((ref) => null);
final organizeRotationsProvider = StateProvider<Map<int, int>>((ref) => {});

class OrganizeScreen extends ConsumerWidget {
  const OrganizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizeControllerProvider);
    final ctrl = ref.read(organizeControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    final filePath = state.files.isEmpty ? null : state.files.first.path;
    final pageCountAsync =
        filePath == null ? null : ref.watch(pdfPageCountProvider(filePath));
    final thumbsAsync =
        filePath == null ? null : ref.watch(pdfThumbsProvider(filePath));

    void resetAll() {
      ref.read(organizeOrderProvider.notifier).state = null;
      ref.read(organizeRotationsProvider.notifier).state = {};
    }

    Future<void> pickFile() async {
      resetAll();
      await ctrl.pickFiles(allowedExtensions: const ['pdf']);
    }

    void clearAll() {
      resetAll();
      ctrl.clearFiles();
    }

    return ToolScaffold(
      title: 'Organize Pages',
      subtitle: 'Long-press and drag to reorder · ⧉ duplicate · ↻ rotate · ✕ delete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerCard(
            files: state.files,
            allowedExtensions: const ['pdf'],
            label: 'PDF to organize',
            onPick: pickFile,
            onClear: clearAll,
          ),
          const SizedBox(height: 12),
          if (filePath != null)
            pageCountAsync?.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Could not read page count: $e'),
                  data: (count) => _WorkingGrid(
                    count: count,
                    thumbsAsync: thumbsAsync,
                    onReset: resetAll,
                  ),
                ) ??
                const SizedBox.shrink(),
          const SizedBox(height: 12),
          if (state.isProcessing) const ToolProgress(label: 'Organizing…'),
          if (state.hasError) ToolError(message: state.message ?? 'Failed', onRetry: ctrl.run),
          if (state.hasResult)
            ToolSuccess(
              message: 'Organized!',
              onOpen: () => openDoc(context, state.resultFiles.first.path),
              onShare: ctrl.shareResult,
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: state.files.isEmpty || state.isProcessing
                ? null
                : () => runWithRename(
                    context: context, ctrl: ctrl, defaultName: defaultOutputName('Organized')),
            icon: const Icon(Icons.view_carousel_outlined),
            label: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _WorkingGrid extends ConsumerWidget {
  const _WorkingGrid({required this.count, required this.thumbsAsync, required this.onReset});

  final int count;
  final AsyncValue<List<String>>? thumbsAsync;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final natural = [for (var i = 0; i < count; i++) i];
    final order = ref.watch(organizeOrderProvider) ?? natural;
    final rotations = ref.watch(organizeRotationsProvider);
    final thumbs = thumbsAsync?.valueOrNull;

    void setOrder(List<int> next) => ref.read(organizeOrderProvider.notifier).state = next;

    void reorder(int from, int to) {
      final next = [...order];
      final item = next.removeAt(from);
      next.insert(to > from ? to - 1 : to, item);
      setOrder(next);
    }

    void duplicate(int pos) {
      final next = [...order];
      next.insert(pos + 1, next[pos]);
      setOrder(next);
    }

    void removeAt(int pos) {
      final next = [...order]..removeAt(pos);
      setOrder(next);
    }

    void rotate(int pos) {
      final orig = order[pos];
      final next = {...rotations};
      next[orig] = ((next[orig] ?? 0) + 90) % 360;
      if (next[orig] == 0) next.remove(orig);
      ref.read(organizeRotationsProvider.notifier).state = next;
    }

    final dupCount = order.length - order.toSet().length;
    final deletedCount = count - order.toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(
            child: Text(
              '${order.length} pages'
              '${dupCount > 0 ? ' · $dupCount duplicated' : ''}'
              '${deletedCount > 0 ? ' · $deletedCount deleted' : ''}'
              '${rotations.isNotEmpty ? ' · ${rotations.length} rotated' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset'),
          ),
        ]),
        const SizedBox(height: 8),
        if (order.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('All pages removed — tap Reset to restore them.',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          )
        else if (thumbsAsync is AsyncLoading)
          const Center(
              child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (thumbsAsync is AsyncError)
          Text('Previews unavailable — you can still apply changes.',
              style: Theme.of(context).textTheme.bodySmall)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.58,
            ),
            itemCount: order.length,
            itemBuilder: (context, pos) {
              final orig = order[pos];
              final thumb = (thumbs != null && orig < thumbs.length) ? thumbs[orig] : null;
              final tile = _OrganizeTile(
                position: pos + 1,
                original: orig + 1,
                thumbPath: thumb,
                rotation: rotations[orig] ?? 0,
                onDuplicate: () => duplicate(pos),
                onRotate: () => rotate(pos),
                onDelete: () => removeAt(pos),
              );
              return DragTarget<int>(
                onAcceptWithDetails: (details) => reorder(details.data, pos),
                builder: (context, candidate, rejected) => Container(
                  decoration: candidate.isNotEmpty
                      ? BoxDecoration(
                          border: Border.all(color: scheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: LongPressDraggable<int>(
                    data: pos,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(width: 100, height: 150, child: tile),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: tile),
                    child: tile,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _OrganizeTile extends StatelessWidget {
  const _OrganizeTile({
    required this.position,
    required this.original,
    required this.thumbPath,
    required this.rotation,
    required this.onDuplicate,
    required this.onRotate,
    required this.onDelete,
  });

  final int position;
  final int original;
  final String? thumbPath;
  final int rotation;
  final VoidCallback onDuplicate;
  final VoidCallback onRotate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: scheme.shadow.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbPath != null)
                    Image.file(File(thumbPath!), fit: BoxFit.cover, width: double.infinity)
                  else
                    Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.picture_as_pdf_rounded,
                          size: 28, color: scheme.onSurfaceVariant),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('$position',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('p$original',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (rotation != 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: scheme.primary, borderRadius: BorderRadius.circular(999)),
                        child: Text('↻$rotation°',
                            style: TextStyle(
                                color: scheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TileButton(
                      icon: Icons.copy_rounded, tooltip: 'Duplicate page', onTap: onDuplicate),
                  _TileButton(
                      icon: Icons.rotate_right_rounded, tooltip: 'Rotate 90°', onTap: onRotate),
                  _TileButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Delete page',
                      onTap: onDelete,
                      danger: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({required this.icon, required this.tooltip, required this.onTap, this.danger = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: tooltip,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: danger ? scheme.errorContainer : scheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 15,
              color: danger ? scheme.onErrorContainer : scheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
