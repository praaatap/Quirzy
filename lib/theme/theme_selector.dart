// lib/theme/theme_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    
    return SimpleDialog(
      title: const Text('Select Theme'),
      children: [
        RadioListTile<AppTheme>(
          title: const Text('Light Theme'),
          value: AppTheme.light,
          groupValue: currentTheme,
          onChanged: (value) {
            ref.read(themeProvider.notifier).setTheme(value!);
            Navigator.pop(context);
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('Dark Theme'),
          value: AppTheme.dark,
          groupValue: currentTheme,
          onChanged: (value) {
            ref.read(themeProvider.notifier).setTheme(value!);
            Navigator.pop(context);
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('System Default'),
          value: AppTheme.system,
          groupValue: currentTheme,
          onChanged: (value) {
            ref.read(themeProvider.notifier).setTheme(value!);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}