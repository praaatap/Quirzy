import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  const ReusableTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black45),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
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
        TextField(obscureText: obscureText, decoration: inputDecoration),
      ],
    );
  }
}
