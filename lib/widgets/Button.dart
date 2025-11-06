import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? child;
  final double? widthFactor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool fullWidth;
  final bool isLoading;

  const ReusableButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.child,
    this.widthFactor = 0.8,
    this.height = 48,
    this.borderRadius = 32,
    this.padding,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine button colors based on theme and props
    final bgColor = backgroundColor ?? colorScheme.primary;
    final fgColor = foregroundColor ?? colorScheme.onPrimary;
    final disabledBgColor = theme.disabledColor;
    
    // Button content
    final buttonChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          )
        : (child ??
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w500,
              ),
            ));

    // Button style
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: onPressed == null ? disabledBgColor : bgColor,
      foregroundColor: fgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      elevation: 0,
      minimumSize: Size(double.infinity, height),
    );

    // Button widget
    final button = ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    return fullWidth
        ? button
        : FractionallySizedBox(
            widthFactor: widthFactor,
            child: button,
          );
  }
}