import 'package:flutter/material.dart';

/// Shared button — never imports Bloc/Repository. Driven by `isLoading` from Mutation Bloc status.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label),
          ]);

    if (isOutlined) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
    }
    return FilledButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  const AppIconButton({super.key, required this.icon, required this.onPressed, this.tooltip});
  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: tooltip);
  }
}
