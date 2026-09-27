import 'package:flutter/material.dart';

/// Shared button — never imports Bloc/Repository. Driven by `isLoading` from Mutation Bloc status.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Filled buttons use onPrimary text; the spinner must match it
              // (white breaks on light-primary dark themes).
              color: isOutlined
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }
    return FilledButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  const new({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: tooltip);
  }
}
