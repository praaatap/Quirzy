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
      extendBody: true, // Allows body to extend behind navbar
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: RepaintBoundary(
        child: _buildNavigationBar(context, selectedIndex),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, int selectedIndex) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Same colors as History/Home screens
    const primaryColor = Color(0xFF5B13EC);
    const textSub = Color(0xFF664C9A);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161022) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          // Solid purple indicator for white icons
          indicatorColor: primaryColor,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // Label styling
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return theme.textTheme.labelMedium?.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
              color: isSelected ? primaryColor : textSub.withOpacity(0.7),
            );
          }),
          // Icon styling - WHITE when selected, purple tint when not
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: isSelected ? Colors.white : textSub.withOpacity(0.7),
            );
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            ref.read(tabIndexProvider.notifier).state = index;
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 60,
          animationDuration: const Duration(milliseconds: 400),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style_rounded, color: Colors.white),
              label: 'Cards',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded, color: Colors.white),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
