import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/features/flashcards/screens/flashcards_screen.dart';
import 'package:quirzy/features/history/screens/history_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
import 'package:quirzy/features/profile/presentation/screens/profile_screen.dart';

import 'package:quirzy/providers/tab_index_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Cache screens for performance - prevents unnecessary rebuilds
  static const List<Widget> _screens = [
    RepaintBoundary(child: HomeScreen()),
    RepaintBoundary(child: FlashcardsScreen()),
    RepaintBoundary(child: HistoryScreen()),
    RepaintBoundary(child: ProfileSettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: _buildMaterial3NavigationBar(context, selectedIndex),
    );
  }

  Widget _buildMaterial3NavigationBar(BuildContext context, int selectedIndex) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Premium Colors
    const primaryColor = Color(0xFF5B13EC);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        indicatorColor: primaryColor,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return theme.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : primaryColor)
                : (isDark ? Colors.white54 : const Color(0xFF64748B)),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white54 : const Color(0xFF64748B)),
          );
        }),
        elevation: 0,
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          ref.read(tabIndexProvider.notifier).state = index;
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}