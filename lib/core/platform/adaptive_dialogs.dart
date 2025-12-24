import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'platform_core.dart';

/// Adaptive dialog that uses platform conventions
Future<T?> showNativeDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  String? cancelText,
  String? confirmText,
  Color? confirmColor,
  bool isDestructive = false,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Widget? icon,
}) {
  final theme = Theme.of(context);

  if (PlatformAdaptive.isIOS) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
          if (confirmText != null)
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: icon,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        style: GoogleFonts.poppins(),
        textAlign: TextAlign.center,
      ),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text(
              cancelText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (confirmText != null)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  confirmColor ??
                  (isDestructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    ),
  );
}
