import 'package:flutter/material.dart';

/// Adaptive bottom sheet that feels native on both platforms
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
}) {
  final theme = Theme.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor ?? theme.colorScheme.surface,
    elevation: elevation ?? 0,
    shape:
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          builder(context),
        ],
      ),
    ),
  );
}

/// Model for adaptive sheet action
class AdaptiveSheetAction<T> {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isDestructive;
  final T? value;
  final VoidCallback? onPressed;

  const AdaptiveSheetAction({
    required this.label,
    this.icon,
    this.color,
    this.isDestructive = false,
    this.value,
    this.onPressed,
  });
}
