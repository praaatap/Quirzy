import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? BorderSideColour;
  const ReusableTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.controller,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.BorderSideColour,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      prefixIcon: prefixIcon,
      filled: true,
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
 
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          
        ),
      ],
    );
  }
}
