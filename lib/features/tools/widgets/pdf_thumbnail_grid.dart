import 'package:flutter/material.dart';

/// Performant thumbnail grid — ListView.builder + RepaintBoundary, 60fps.
class PdfThumbnailGrid extends StatelessWidget {
  const PdfThumbnailGrid({
    required this.pageCount,
    super.key,
    this.onReorder,
    this.onDelete,
    this.onRotate,
    this.selectedPages,
    this.onTap,
  });

  final int pageCount;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final void Function(int index)? onDelete;
  final void Function(int index)? onRotate;
  final Set<int>? selectedPages;

  /// Tap anywhere on a tile (used by Extract to toggle selection).
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    if (pageCount == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Center(child: Text('No pages — pick a PDF first', style: Theme.of(context).textTheme.bodyMedium)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: pageCount,
      itemBuilder: (context, index) {
        final selected = selectedPages?.contains(index) ?? false;
        return RepaintBoundary(
          child: _PageTile(
            pageNumber: index + 1,
            selected: selected,
            onDelete: onDelete != null ? () => onDelete!(index) : null,
            onRotate: onRotate != null ? () => onRotate!(index) : null,
            onTap: onTap != null ? () => onTap!(index) : null,
          ),
        );
      },
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile(
      {required this.pageNumber, required this.selected, this.onDelete, this.onRotate, this.onTap});
  final int pageNumber;
  final bool selected;
  final VoidCallback? onDelete;
  final VoidCallback? onRotate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5), width: selected ? 1.8 : 1),
        boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest, shape: BoxShape.circle),
                    child: Icon(Icons.picture_as_pdf_rounded, size: 28, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text('Page $pageNumber', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 6,
                right: 6,
                child: Semantics(
                  label: 'Delete page $pageNumber',
                  button: true,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: scheme.errorContainer, shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, size: 14, color: scheme.onErrorContainer),
                    ),
                  ),
                ),
              ),
            if (onRotate != null)
              Positioned(
                bottom: 6,
                right: 6,
                child: Semantics(
                  label: 'Rotate page $pageNumber',
                  button: true,
                  child: InkWell(
                    onTap: onRotate,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.rotate_right_rounded, size: 14, color: scheme.onSecondaryContainer),
                    ),
                  ),
                ),
              ),
            if (selected)
              Positioned(
                top: 8,
                left: 8,
                child: Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
