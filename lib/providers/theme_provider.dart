import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system) {
    _loadTheme();
    _setupSystemThemeListener();
  }

  static const _themeKey = 'theme';
  Brightness? _currentSystemBrightness;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? AppTheme.system.index;
    state = AppTheme.values[themeIndex];
    _currentSystemBrightness = WidgetsBinding.instance.window.platformBrightness;
  }

  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  void _setupSystemThemeListener() {
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      if (state == AppTheme.system) {
        _currentSystemBrightness = WidgetsBinding.instance.window.platformBrightness;
        // Notify listeners by setting the same theme again
        setTheme(AppTheme.system);
      }
    };
  }

  ThemeMode get themeMode {
    if (state == AppTheme.system) {
      return _currentSystemBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light;
    }
    return state == AppTheme.dark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode {
    if (state == AppTheme.system) {
      return _currentSystemBrightness == Brightness.dark;
    }
    return state == AppTheme.dark;
  }
}