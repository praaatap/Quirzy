import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// =========================================================
/// 🎨 1. PALETTE (Purple Theme - #5B13EC)
/// =========================================================
class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF5B13EC); // Main Purple
  static const Color lightPrimaryLight = Color(0xFFEFE9FD); // Light Purple Tint
  static const Color lightPrimaryDark = Color(0xFF4A0FBF); // Darker Purple
  static const Color lightSecondary = Color(0xFFEC4899); // Pink accent
  static const Color lightBackground = Color(
    0xFFF9F8FC,
  ); // Off-white with purple tint
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Light gray
  static const Color lightText = Color(0xFF120D1B); // Near black
  static const Color lightTextSecondary = Color(0xFF664C9A); // Muted purple

  // Dark Theme Colors
  static const Color darkPrimary = Color(
    0xFF7C3AED,
  ); // Brighter purple for dark mode
  static const Color darkPrimaryLight = Color(0xFF9333EA); // Lighter purple
  static const Color darkPrimaryDark = Color(0xFF5B13EC); // Deep purple base
  static const Color darkSecondary = Color(0xFFF472B6); // Brighter pink accent
  static const Color darkBackground = Color(0xFF0F0F0F); // Premium nearly-black
  static const Color darkSurface = Color(0xFF1A1A1A); // Neutral dark surface
  static const Color darkSurfaceVariant = Color(
    0xFF262626,
  ); // Lighter neutral surface
  static const Color darkText = Color(0xFFFFFFFF); // Pure white
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Neutral grey text

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
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
  QuizColors copyWith({
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? surfaceSubtle,
  }) {
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
    // Using apply() strongly enforces the base colors across ALL text styles
    // (display, headline, title, body, label) so nothing defaults to black/purple.
    return GoogleFonts.plusJakartaSansTextTheme()
        .apply(bodyColor: primary, displayColor: primary)
        .copyWith(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
          // Body styles
          bodyLarge: TextStyle(fontSize: 16, color: primary),
          bodyMedium: TextStyle(fontSize: 14, color: secondary),
          bodySmall: TextStyle(fontSize: 12, color: secondary),
          // Ensure titles/labels are also correct
          titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: secondary, fontWeight: FontWeight.w500),
          labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: secondary, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: secondary, fontWeight: FontWeight.w500),
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

      textTheme: _buildTextTheme(
        AppColors.lightText,
        AppColors.lightTextSecondary,
      ),

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
          minimumSize: const Size(
            double.infinity,
            56,
          ), // Taller buttons are easier to tap
          shape: RoundedRectangleBorder(borderRadius: _defaultRadius),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: BorderSide.none,
        ),
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
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkPrimaryDark,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextSecondary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        error: AppColors.error,
        outline: Color(0xFF404040), // Subtle divider color
      ),

      // ✅ Essential for FlashcardsScreen to work
      extensions: [
        const QuizColors(
          success: AppColors.success,
          error: AppColors.error,
          warning: AppColors.warning,
          info: AppColors.info,
          surfaceSubtle: AppColors.darkSurfaceVariant,
        ),
      ],

      textTheme: _buildTextTheme(
        AppColors.darkText,
        AppColors.darkTextSecondary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: _defaultRadius,
          side: const BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ), // Subtle high-quality border
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: _defaultRadius),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),

      // 🚫 STOP PURPLE TEXT LEAKS
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkText,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white, // Buttons are white, not purple
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: AppColors.darkTextSecondary.withOpacity(0.5),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.darkPrimary),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
        border: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
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
