// lib/theme/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/theme_provider.dart';
import 'package:quirzy/theme/theme_selector.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return IconButton(
      icon: _getThemeIcon(themeMode),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const ThemeSelector(),
        );
      },
    );
  }

  Widget _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Icon(Icons.light_mode);
      case AppTheme.dark:
        return const Icon(Icons.dark_mode);
      case AppTheme.system:
        return const Icon(Icons.brightness_auto);
    }
  }
}