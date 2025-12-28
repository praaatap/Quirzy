import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// =========================================================
/// 🎨 1. PALETTE (Your New Blue Definitions)
/// =========================================================
class AppColors {
  // Light Theme
  static const Color lightPrimary = Color(0xFF1976D2); // Blue 700
  static const Color lightPrimaryLight = Color(0xFF42A5F5); // Blue 400
  static const Color lightSecondary = Color(0xFF00ACC1); // Cyan 600
  static const Color lightBackground = Color(0xFFF8FAFC); // Slight off-white for depth
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightText = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500

  // Dark Theme
  static const Color darkPrimary = Color(0xFF42A5F5); // Blue 400
  static const Color darkPrimaryDark = Color(0xFF1565C0); // Blue 800
  static const Color darkSecondary = Color(0xFF26C6DA); // Cyan 400
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkText = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

/// =========================================================
/// 🧩 2. THEME EXTENSION (Required for Flashcards Screen)
/// =========================================================
@immutable
class QuizColors extends ThemeExtension<QuizColors> {
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color surfaceSubtle;

  const QuizColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.surfaceSubtle,
  });

  @override
  QuizColors copyWith({Color? success, Color? error, Color? warning, Color? info, Color? surfaceSubtle}) {
    return QuizColors(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
    );
  }

  @override
  QuizColors lerp(ThemeExtension<QuizColors>? other, double t) {
    if (other is! QuizColors) return this;
    return QuizColors(
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
    );
  }
}

/// =========================================================
/// 🛠 3. APP THEME BUILDER
/// =========================================================
class AppTheme {
  static final BorderRadius _defaultRadius = BorderRadius.circular(12);

  static void initialize() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    // You can swap this back to Roboto if you prefer, 
    // but Plus Jakarta Sans looks more modern for "Quiz" apps.
    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: secondary),
    );
  }

  // ☀️ LIGHT THEME
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimary,

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.lightPrimaryLight,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        onSurfaceVariant: AppColors.lightTextSecondary,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        error: AppColors.error,
      ),

      // ✅ Essential for FlashcardsScreen to work
      extensions: [
        const QuizColors(
          success: AppColors.success,
          error: AppColors.error,
          warning: AppColors.warning,
          info: AppColors.info,
          surfaceSubtle: AppColors.lightSurfaceVariant,
        ),
      ],

      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextSecondary),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _defaultRadius,
          side: const BorderSide(color: Color(0xFFE2E8F0)), // Subtle border
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56), // Taller buttons are easier to tap
          shape: RoundedRectangleBorder(borderRadius: _defaultRadius),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(borderRadius: _defaultRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: _defaultRadius, 
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
      ),
    );
  }

  // 🌙 DARK THEME
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: Colors.black, // Dark mode primary text is usually black on blue
        primaryContainer: AppColors.darkPrimaryDark,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextSecondary,
        error: AppColors.error,
      ),

      // ✅ Essential for FlashcardsScreen to work
      extensions: [
        const QuizColors(
          success: AppColors.success,
          error: AppColors.error,
          warning: AppColors.warning,
          info: AppColors.info,
          surfaceSubtle: Color(0xFF334155), // Slate 700
        ),
      ],

      textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextSecondary),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _defaultRadius,
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.black, // High contrast text
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: _defaultRadius),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B), // Slate 800
        border: OutlineInputBorder(borderRadius: _defaultRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: _defaultRadius, 
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),
    );
  }
}

/// =========================================================
/// 🛠 4. HELPER EXTENSION (Clean Code Access)
/// =========================================================
extension BuildContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
  QuizColors get quizColors => Theme.of(this).extension<QuizColors>()!;
}