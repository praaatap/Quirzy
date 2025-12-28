import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;

  // ✅ Changed to Widget? to allow IconButton (for clicks)
  final Widget? suffixIcon;

  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;

  // ignore: non_constant_identifier_names
  final Color? borderSideColor;

  const ReusableTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon, // ✅ Added to constructor
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.controller,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.borderSideColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputDecoration = InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon, // ✅ Pass it to InputDecoration
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
        0.3,
      ), // Modern fill color
      hintText: hintText,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

      // Default Border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          // Use the custom color if provided, otherwise transparent/outline
          color: borderSideColor ?? Colors.transparent,
          width: 1,
        ),
      ),

      // Focused Border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),

      // Error Border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),

      // Focused Error Border
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14, // Slightly smaller for modern look
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          decoration: inputDecoration,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          controller: controller,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
