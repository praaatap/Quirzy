import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/flashcards/screens/flashcards_screen.dart';
import 'package:quirzy/features/history/screens/history_screen.dart';
import 'package:quirzy/features/home/screens/home_screen.dart';
import 'package:quirzy/features/profile/screens/profile_screen.dart';
import 'package:quirzy/features/settings/screens/settings_screen.dart';
import 'package:quirzy/providers/tab_index_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;

  // Flag to prevent race condition during programmatic page changes
  bool _isAnimating = false;

  // Cache screens for performance
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize controller with the current state from provider
    final initialPage = ref.read(tabIndexProvider);
    _pageController = PageController(
      initialPage: initialPage,
      // Keep 1 page on each side in memory for smoother transitions
      viewportFraction: 1.0,
    );

    // Pre-build screens with RepaintBoundary for rendering isolation
    _screens = const [
      RepaintBoundary(child: HomeScreen()),
      RepaintBoundary(child: FlashcardsScreen()),
      RepaintBoundary(child: HistoryScreen()),
      RepaintBoundary(child: ProfileScreen()),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(tabIndexProvider);
    final navbarStyle = ref.watch(settingsProvider).navbarStyle;

    // Listen to the provider. When the Navbar changes the state,
    // we animate the PageView to the new index.
    ref.listen<int>(tabIndexProvider, (previous, next) {
      if (_pageController.hasClients && next != _pageController.page?.round()) {
        // Set flag to prevent onPageChanged from updating provider during animation
        _isAnimating = true;
        _pageController
            .animateToPage(
              next,
              // Faster, smoother animation
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            )
            .then((_) {
              // Reset flag after animation completes
              _isAnimating = false;
            });
      }
    });

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // High-performance PageView with optimized physics
          PageView.builder(
            controller: _pageController,
            physics: const _HighPerformancePagePhysics(),
            onPageChanged: (index) {
              // Only update provider if this is a user swipe, not a programmatic animation
              if (!_isAnimating) {
                ref.read(tabIndexProvider.notifier).state = index;
              }
            },
            itemCount: _screens.length,
            itemBuilder: (context, index) {
              // Use TickerMode to pause animations on non-visible pages
              return TickerMode(
                enabled: selectedIndex == index,
                child: _screens[index],
              );
            },
          ),

          // Navbar
          if (navbarStyle == 'custom')
            Positioned(
              left: 20,
              right: 20,
              bottom: 20 + MediaQuery.of(context).padding.bottom,
              child: RepaintBoundary(
                child: _ModernFloatingNavBar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    HapticFeedback.lightImpact();
                    ref.read(tabIndexProvider.notifier).state = index;
                  },
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RepaintBoundary(
                child: _Material3NavBar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    HapticFeedback.lightImpact();
                    ref.read(tabIndexProvider.notifier).state = index;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// High-performance page physics with smooth scrolling
class _HighPerformancePagePhysics extends ScrollPhysics {
  const _HighPerformancePagePhysics({super.parent});

  @override
  _HighPerformancePagePhysics applyTo(ScrollPhysics? ancestor) {
    return _HighPerformancePagePhysics(
      parent: buildParent(ancestor) ?? const ClampingScrollPhysics(),
    );
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 50, // Lower mass = faster response
    stiffness: 100, // Higher stiffness = snappier
    damping: 1, // Critical damping for smooth stop
  );
}

// ==========================================
// MODERN FLOATING NAVBAR (Unchanged logic)
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

    final double alignmentX = -1.0 + (selectedIndex * (2.0 / 3));

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.95),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(alignmentX, 0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.fastOutSlowIn,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 4;
                  return Container(
                    width: itemWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
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
                  icon: Icons.style_outlined,
                  activeIcon: Icons.style_rounded,
                  label: "Cards",
                  index: 1,
                  isSelected: selectedIndex == 1,
                  onTap: onItemSelected,
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history_rounded,
                  label: "History",
                  index: 2,
                  isSelected: selectedIndex == 2,
                  onTap: onItemSelected,
                  theme: theme,
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: "Profile",
                  index: 3,
                  isSelected: selectedIndex == 3,
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
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
// MATERIAL 3 NAVBAR
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
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 11,
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
        height: 70,
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
