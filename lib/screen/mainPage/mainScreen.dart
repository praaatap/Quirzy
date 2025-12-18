import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/screen/history/history_screen.dart';
import 'package:quirzy/screen/mainPage/homeScreen.dart';
import 'package:quirzy/screen/profile/profile_screen.dart';
import 'package:quirzy/screen/settings/settings_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(tabIndexProvider);
    // You can default to 'custom' if you want this to be the default
    final navbarStyle = ref.watch(settingsProvider).navbarStyle; 

    return Scaffold(
      extendBody: true, // Allows content to go behind the navbar
      body: Stack(
        children: [
          // Main Content Screens
          IndexedStack(
            index: selectedIndex,
            children: const [
              HomeScreen(),
              HistoryScreen(),
              // VersusPage(),
              ProfileScreen(),
            ],
          ),

          // Navbar Positioning
          if (navbarStyle == 'custom')
            Positioned(
              left: 24, // Floating margin
              right: 24,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: _ModernFloatingNavBar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  HapticFeedback.lightImpact();
                  ref.read(tabIndexProvider.notifier).state = index;
                },
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Material3NavBar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  HapticFeedback.lightImpact();
                  ref.read(tabIndexProvider.notifier).state = index;
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. MODERN FLOATING NAVBAR (Performance Optimized)
// ==========================================

class _ModernFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _ModernFloatingNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Alignment Logic for 3 items: -1.0 (Left), 0.0 (Center), 1.0 (Right)
    final double alignmentX = -1.0 + selectedIndex;

    return Container(
      height: 72, // Compact height
      decoration: BoxDecoration(
        // High opacity surface instead of expensive Blur
        color: theme.colorScheme.surfaceContainer.withOpacity(0.95),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          // Soft static shadow (cheap to render)
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Padding for the internal pill
        child: Stack(
          children: [
            // LAYER 1: Animated Indicator Pill
            AnimatedAlign(
              alignment: Alignment(alignmentX, 0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.fastOutSlowIn, // Snappy feeling
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Divide by 3 items
                  final itemWidth = constraints.maxWidth / 3;
                  return Container(
                    width: itemWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      // Gradient Pill for "Modern" look
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // LAYER 2: Icons
            Row(
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  isSelected: selectedIndex == 0,
                  onTap: onItemSelected,
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history_rounded,
                  label: "History",
                  index: 1,
                  isSelected: selectedIndex == 1,
                  onTap: onItemSelected,
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "Profile",
                  index: 2,
                  isSelected: selectedIndex == 2,
                  onTap: onItemSelected,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isSelected;
  final Function(int) onTap;
  final ThemeData theme;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected), // Important for animation
                size: 26,
                // If selected, use onPrimary (White text on colored pill)
                // If not, use onSurfaceVariant (Grey)
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 2),

            // Label (Only shows when selected, or always if you prefer)
            if (isSelected)
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimary,
                ),
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. STANDARD MATERIAL 3 NAVBAR (Fallback)
// ==========================================

class _Material3NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _Material3NavBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 12, 
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 12, 
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        backgroundColor: theme.colorScheme.surface,
        elevation: 3,
        indicatorColor: theme.colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70, // Slightly shorter for modern look
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}