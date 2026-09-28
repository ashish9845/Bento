import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:scan/features/tools/providers/tool_state.dart';
import 'package:scan/features/tools/widgets/file_picker_card.dart';
import 'package:scan/features/tools/widgets/rename_dialog.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class OrganizeScreen extends StatefulWidget {
  const new({super.key, this.repository});

  /// Overridable for tests; defaults to the real FFI engine repository.
  final ToolsRepository? repository;

  @override
  State<OrganizeScreen> createState() => _OrganizeScreenState();
}

class _OrganizeScreenState extends State<OrganizeScreen> {
  late final ToolCubit _cubit;

  /// Working page order as original 0-based indices. Duplicates allowed,
  /// deletions are items removed from the list. `null` = untouched natural order.
  List<int>? _order;
  Map<int, int> _rotations = {};
  Future<(_PageCount, List<File>)?>? _docFuture;
  String? _docPath;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? ToolsRepositoryImpl(PdfEngineDataSourceImpl());
    _cubit = ToolCubit(
      repository: repository,
      persistenceKey: 'organize',
      processFn: (inputs, ctrl) async {
        final count = await repository.pageCount(inputs.first);
        final natural = [for (var i = 0; i < count; i++) i];
        final order = _order ?? natural;
        if (order.isEmpty) {
          throw Exception('No pages left — tap Reset to restore them');
        }
        ctrl.setProgress(null, 'Applying changes to ${order.length} pages…');
        final out = await repository.organizePdf(
          inputs.first,
          order: order,
          rotations: _rotations,
          outputName: ctrl.outputName,
        );
        return [out];
      },
    );
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  void _onFilesChanged(ToolState state) {
    final path = state.files.isEmpty ? null : state.files.first.path;
    if (path != _docPath) {
      setState(() {
        _docPath = path;
        if (path == null) {
          _docFuture = null;
        } else {
          final file = File(path);
          _docFuture =
              Future.wait([_cubit.pageCount(file), _cubit.thumbnails(file)])
                  .then<(_PageCount, List<File>)?>(
                    (results) => (
                      _PageCount(count: results[0] as int),
                      results[1] as List<File>,
                    ),
                  );
        }
      });
    }
  }

  void _resetAll() {
    setState(() {
      _order = null;
      _rotations = {};
    });
  }

  Future<void> _pickFile() async {
    _resetAll();
    await _cubit.pickFiles(allowedExtensions: const ['pdf']);
  }

  void _clearAll() {
    _resetAll();
    _cubit.clearFiles();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ToolCubit, ToolState>(
        listener: (context, state) => _onFilesChanged(state),
        builder: (context, state) {
          return ToolScaffold(
            title: 'Organize Pages',
            subtitle: 'Long-press and drag to reorder · ⧉ duplicate · ↻ rotate · ✕ delete',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilePickerCard(
                  files: state.files,
                  fileSizes: state.fileSizes,
                  allowedExtensions: const ['pdf'],
                  label: 'PDF to organize',
                  onPick: _pickFile,
                  onClear: _clearAll,
                ),
                const SizedBox(height: 12),
                if (_docPath != null && _docFuture != null)
                  FutureBuilder<(_PageCount, List<File>)?>(
                    future: _docFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError || snap.data == null) {
                        return const Text(
                          'Could not read pages — pick the file again.',
                        );
                      }
                      final (info, thumbs) = snap.data!;
                      return _WorkingGrid(
                        count: info.count,
                        thumbPaths: [for (final t in thumbs) t.path],
                        order: _order,
                        rotations: _rotations,
                        onOrderChanged: (next) => setState(() => _order = next),
                        onRotationsChanged: (next) =>
                            setState(() => _rotations = next),
                        onReset: _resetAll,
                      );
                    },
                  ),
                const SizedBox(height: 12),
                if (state.isProcessing)
                  const ToolProgress(label: 'Organizing…'),
                if (state.hasError)
                  ToolError(
                    message: state.message ?? 'Failed',
                    onRetry: _cubit.run,
                  ),
                if (state.hasResult)
                  ToolSuccess(
                    message: 'Organized!',
                    onOpen: () =>
                        openDoc(context, state.resultFiles.first.path),
                    onShare: _cubit.shareResult,
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.files.isEmpty || state.isProcessing
                      ? null
                      : () => runWithRename(
                          context: context,
                          ctrl: _cubit,
                          defaultName: defaultOutputName('Organized'),
                        ),
                  icon: const Icon(Icons.view_carousel_outlined),
                  label: const Text('Apply'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Page-count payload for the organize grid future.
class _PageCount {
  const new({required this.count});
  final int count;
}

class _WorkingGrid extends StatelessWidget {
  const new({
    required this.count,
    required this.thumbPaths,
    required this.order,
    required this.rotations,
    required this.onOrderChanged,
    required this.onRotationsChanged,
    required this.onReset,
  });

  final int count;
  final List<String> thumbPaths;
  final List<int>? order;
  final Map<int, int> rotations;
  final ValueChanged<List<int>> onOrderChanged;
  final ValueChanged<Map<int, int>> onRotationsChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final natural = [for (var i = 0; i < count; i++) i];
    final current = order ?? natural;
    final thumbs = thumbPaths.isEmpty ? null : thumbPaths;

    void reorder(int from, int to) {
      // `to` is the cell dropped onto (0..n-1, pre-removal coordinates).
      // Unlike ReorderableListView.onReorder — where newIndex can point past
      // the end and needs a -1 correction — a cell index stays valid after
      // removal, so insert directly at `to`: the dragged page takes that
      // cell's slot. (The old `to - 1` adjustment made every adjacent move
      // a silent no-op: page 1 dropped on page 2 landed back where it was.)
      final next = [...current];
      final item = next.removeAt(from);
      next.insert(to, item);
      onOrderChanged(next);
    }

    void duplicate(int pos) {
      final next = [...current];
      next.insert(pos + 1, next[pos]);
      onOrderChanged(next);
    }

    void removeAt(int pos) {
      final next = [...current]..removeAt(pos);
      onOrderChanged(next);
    }

    void rotate(int pos) {
      final orig = current[pos];
      final next = {...rotations};
      next[orig] = ((next[orig] ?? 0) + 90) % 360;
      if (next[orig] == 0) next.remove(orig);
      onRotationsChanged(next);
    }

    final dupCount = current.length - current.toSet().length;
    final deletedCount = count - current.toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${current.length} pages'
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
          ],
        ),
        const SizedBox(height: 8),
        if (current.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'All pages removed — tap Reset to restore them.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
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
            itemCount: current.length,
            itemBuilder: (context, pos) {
              final orig = current[pos];
              final thumb = (thumbs != null && orig < thumbs.length)
                  ? thumbs[orig]
                  : null;
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
                          borderRadius: BorderRadius.circular(8),
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
  const new({
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbPath != null)
                    Image.file(
                      File(thumbPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  else
                    ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 28,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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
                        '$position',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'p$original',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (rotation != 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '↻$rotation°',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
                    icon: Icons.copy_rounded,
                    tooltip: 'Duplicate page',
                    onTap: onDuplicate,
                  ),
                  _TileButton(
                    icon: Icons.rotate_right_rounded,
                    tooltip: 'Rotate 90°',
                    onTap: onRotate,
                  ),
                  _TileButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Delete page',
                    onTap: onDelete,
                    danger: true,
                  ),
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
  const new({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

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
          child: Icon(
            icon,
            size: 15,
            color: danger
                ? scheme.onErrorContainer
                : scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
