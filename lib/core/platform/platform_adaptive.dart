import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Platform-adaptive utilities for native feel
class PlatformAdaptive {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Get platform-specific scroll physics
  static ScrollPhysics get scrollPhysics {
    return isIOS
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  /// Platform-specific page route
  static PageRoute<T> pageRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    if (isIOS) {
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Adaptive haptic feedback based on action type
  static void hapticLight() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  static void hapticMedium() {
    HapticFeedback.mediumImpact();
  }

  static void hapticHeavy() {
    HapticFeedback.heavyImpact();
  }

  static void hapticSelection() {
    HapticFeedback.selectionClick();
  }

  static void hapticSuccess() {
    if (isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  static void hapticError() {
    HapticFeedback.heavyImpact();
  }
}

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

/// Adaptive action sheet for multiple options
Future<T?> showAdaptiveActionSheet<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<AdaptiveSheetAction<T>> actions,
  AdaptiveSheetAction<T>? cancelAction,
}) {
  if (PlatformAdaptive.isIOS) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title != null ? Text(title) : null,
        message: message != null ? Text(message) : null,
        actions: actions
            .map(
              (action) => CupertinoActionSheetAction(
                isDestructiveAction: action.isDestructive,
                onPressed: () {
                  Navigator.pop(context, action.value);
                  action.onPressed?.call();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (action.icon != null) ...[
                      Icon(action.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(action.label),
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: cancelAction != null
            ? CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  cancelAction.onPressed?.call();
                },
                child: Text(cancelAction.label),
              )
            : null,
      ),
    );
  }

  return showAdaptiveBottomSheet<T>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (message != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActionTile(action: action),
              ),
            ),
            if (cancelAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  cancelAction.onPressed?.call();
                },
                child: Text(
                  cancelAction.label,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _ActionTile<T> extends StatelessWidget {
  final AdaptiveSheetAction<T> action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.isDestructive ? theme.colorScheme.error : action.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          PlatformAdaptive.hapticLight();
          Navigator.pop(context, action.value);
          action.onPressed?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: (color ?? theme.colorScheme.primary).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  color: color ?? theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  action.label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: color ?? theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
