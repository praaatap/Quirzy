import 'package:flutter/material.dart';

/// App Theme Configuration
class AppTheme {
  // Neural Bulb Theme: Electric Purple & Glowing Cyan
  static const primaryColor = Color(0xFF6200EA); // Electric Violet
  static const secondaryColor = Color(0xFF00E5FF); // Cyber Cyan
  static const tertiaryColor = Color(0xFFFF2E63); // Idea Magenta

  static ThemeData createTheme({
    ColorScheme? colorScheme,
    required Brightness brightness,
  }) {
    final scheme =
        colorScheme ??
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: brightness,
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get lightTheme => createTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => createTheme(brightness: Brightness.dark);
}
