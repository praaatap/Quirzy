import 'package:flutter/material.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final baseTextColor = isDark ? Colors.white : Colors.black;
  final baseBackgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: baseBackgroundColor,
    fontFamily: 'Roboto',

    // Main Color Scheme
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: isDark ? Colors.blueAccent : Colors.blue.shade800,
      onPrimary: Colors.white,
      secondary: isDark ? Colors.cyanAccent : Colors.cyan.shade600,
      onSecondary: Colors.black,
      error: Colors.red.shade400,
      onError: Colors.white,
      background: baseBackgroundColor,
      onBackground: baseTextColor,
      surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onSurface: baseTextColor,
      surfaceVariant: isDark
          ? Colors.blueGrey.shade800
          : Colors.blueGrey.shade50,
    ),

    // AppBar Styling
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: baseTextColor),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      surfaceTintColor: Colors.transparent,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      selectedItemColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
      unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: isDark
          ? Colors.blueAccent
          : Colors.blue.shade800.withOpacity(0.2),
    ),
    // TabBar Styling
    tabBarTheme: TabBarThemeData(
      labelColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
      unselectedLabelColor: isDark
          ? Colors.grey.shade500
          : Colors.grey.shade600,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: isDark ? Colors.blueAccent : Colors.blue.shade800,
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),

    // Text Themes
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: baseTextColor),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseTextColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: baseTextColor,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      surfaceTintColor: Colors.transparent,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
        side: BorderSide(
          color: isDark ? Colors.blueAccent : Colors.blue.shade800,
          width: 2,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      hintStyle: TextStyle(
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.blueAccent : Colors.blue.shade800,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Icon Theme
    iconTheme: IconThemeData(color: baseTextColor, size: 24),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: isDark ? Colors.blueAccent : Colors.blue.shade800,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return isDark ? Colors.blueAccent : Colors.blue.shade800;
        }
        return isDark ? Colors.grey.shade500 : Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return isDark
              ? Colors.blueAccent.withOpacity(0.5)
              : Colors.blue.shade800.withOpacity(0.5);
        }
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      }),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? Colors.blueGrey.shade800
          : Colors.blueGrey.shade100,
      labelStyle: TextStyle(color: baseTextColor, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      brightness: brightness,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Popup Menu Theme
    popupMenuTheme: PopupMenuThemeData(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(color: baseTextColor, fontSize: 14),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: TextStyle(
        color: baseTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: baseTextColor, fontSize: 14),
    ),
  );
}
