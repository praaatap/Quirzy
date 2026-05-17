/// Theme Configuration - Color schemes and styling
import 'package:flutter/material.dart';

class ThemeConfig {
  // Primary Colors
  static const Color primaryColor = Color(0xFF5B13EC);
  static const Color primaryLight = Color(0xFFEFE9FD);
  static const Color primaryDark = Color(0xFF4A0FC7);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF9333EA);
  static const Color accentColor = Color(0xFFEC4899);
  
  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF9F8FC);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF171717);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF120D1B);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryLight = Color(0xFF664C9A);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  
  // Gradient Presets
  static const List<Color> primaryGradient = [
    primaryColor,
    secondaryColor,
  ];
  
  static const List<Color> successGradient = [
    successColor,
    Color(0xFF059669),
  ];
  
  static const List<Color> warningGradient = [
    warningColor,
    Color(0xFFD97706),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 9999.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  
  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXL = 16.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeHero = 32.0;
}
