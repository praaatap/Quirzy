import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ Color Definitions (keep as is)
class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightPrimaryLight = Color(0xFF42A5F5);
  static const Color lightPrimaryDark = Color(0xFF0D47A1);
  static const Color lightSecondary = Color(0xFF00ACC1);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF42A5F5);
  static const Color darkPrimaryLight = Color(0xFF90CAF9);
  static const Color darkPrimaryDark = Color(0xFF1976D2);
  static const Color darkSecondary = Color(0xFF26C6DA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
}

// ✅ FIX: Move SystemChrome configuration outside theme builder
class AppTheme {
  static void initialize() {
    // Configure once at app startup, not on every theme rebuild
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  static ThemeData light() => buildAppTheme(brightness: Brightness.light);
  static ThemeData dark() => buildAppTheme(brightness: Brightness.dark);
}

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  
  // Adaptive Colors
  final baseTextColor = isDark ? Colors.white : const Color(0xFF212121);
  final secondaryTextColor = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
  final baseBackgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
  final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
  final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
  final cardColor = isDark ? AppColors.darkCardColor : AppColors.lightCardColor;

  // ✅ FIX: Only set status bar style for current theme
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  });

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: baseBackgroundColor,
    fontFamily: 'Roboto',
  
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.darkPrimaryDark : AppColors.lightPrimaryLight,
      onPrimaryContainer: isDark ? AppColors.darkPrimaryLight : AppColors.lightPrimaryDark,
      secondary: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
      onSecondary: isDark ? Colors.black : Colors.white,
      secondaryContainer: isDark ? AppColors.darkSecondary.withOpacity(0.3) : AppColors.lightSecondary.withOpacity(0.2),
      onSecondaryContainer: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
      error: isDark ? AppColors.errorLight : AppColors.error,
      onError: Colors.white,
      errorContainer: isDark ? AppColors.errorDark : AppColors.errorLight.withOpacity(0.2),
      onErrorContainer: isDark ? AppColors.errorLight : AppColors.errorDark,
      surface: surfaceColor,
      onSurface: baseTextColor,
      surfaceContainerHighest: baseBackgroundColor,
      onSurfaceVariant: secondaryTextColor,
      outline: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0),
      outlineVariant: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
      shadow: Colors.black.withOpacity(0.1),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      foregroundColor: baseTextColor,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      indicatorColor: primaryColor.withOpacity(isDark ? 0.3 : 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      elevation: 3,
    ),

    cardTheme: CardThemeData(
      color: cardColor,
      elevation: isDark ? 2 : 1,
      shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Colors.transparent,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: baseTextColor),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: baseTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: baseTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryTextColor),
    ),
  );
}

extension SemanticColors on ThemeData {
  Color get successColor => brightness == Brightness.dark ? AppColors.successLight : AppColors.success;
  Color get warningColor => brightness == Brightness.dark ? AppColors.warningLight : AppColors.warning;
  Color get errorColor => brightness == Brightness.dark ? AppColors.errorLight : AppColors.error;
  Color get infoColor => brightness == Brightness.dark ? AppColors.infoLight : AppColors.info;
}
