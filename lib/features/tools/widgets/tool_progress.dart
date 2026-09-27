import 'package:flutter/material.dart';
import 'package:scan/core/widgets/entrance.dart';

class ToolProgress extends StatelessWidget {
  const new({required this.label, super.key, this.progress, this.onCancel});
  final String label;
  final double? progress;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (onCancel != null)
                  TextButton(onPressed: onCancel, child: const Text('Cancel')),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToolError extends StatelessWidget {
  const new({required this.message, super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: EntranceFadeSlide(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.error.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: scheme.onError,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ToolSuccess extends StatefulWidget {
  const new({
    required this.message,
    super.key,
    this.onSave,
    this.onShare,
    this.onSendTo,
    this.onOpenFolder,
    this.onOpen,
  });
  final String message;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onSendTo;

  /// Opens the result folder (e.g. PDF→Image export). Replaces Save when the
  /// files are already in their final location.
  final VoidCallback? onOpenFolder;

  /// Opens the single result file. Replaces Save for the same reason.
  final VoidCallback? onOpen;

  @override
  State<ToolSuccess> createState() => _ToolSuccessState();
}

class _ToolSuccessState extends State<ToolSuccess>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (widget.onOpenFolder != null)
                    FilledButton.icon(
                      onPressed: widget.onOpenFolder,
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: const Text('Open folder'),
                    ),
                  if (widget.onOpen != null)
                    FilledButton.icon(
                      onPressed: widget.onOpen,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Open'),
                    ),
                  if (widget.onSave != null)
                    FilledButton.icon(
                      onPressed: widget.onSave,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save'),
                    ),
                  if (widget.onShare != null)
                    FilledButton.tonalIcon(
                      onPressed: widget.onShare,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  if (widget.onSendTo != null)
                    OutlinedButton.icon(
                      onPressed: widget.onSendTo,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send to tool'),
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
