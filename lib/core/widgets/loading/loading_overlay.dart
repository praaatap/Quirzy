import 'package:flutter/material.dart';

/// A simple, performant full-screen loading overlay with optional message.
/// Use by placing it above your main UI (Stack) or by returning it directly.
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool visible;
  final bool showProgress;
  final double progressSize;

  const LoadingOverlay({
    super.key,
    this.message,
    this.visible = true,
    this.showProgress = true,
    this.progressSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Stack(
      children: [
        // Semi-transparent barrier that blocks touches below
        ModalBarrier(
          dismissible: false,
          color: theme.colorScheme.background.withOpacity(0.55),
        ),
        // Centered content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showProgress)
                      SizedBox(
                        width: progressSize,
                        height: progressSize,
                        child: const CircularProgressIndicator(strokeWidth: 3),
                      ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
