import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/providers.dart';
import 'home_screen.dart';
import '../../flashcards/screens/flashcards_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/history_screen.dart';
import '../../explore/screens/explore_screen.dart';
import '../../onboarding/screens/exam_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkExamSelection();
  }

  Future<void> _checkExamSelection() async {
    // Check if user has selected an exam preference
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_exam') == null) {
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ExamSelectionScreen()));
      }
    }
  }

  // Screens list
  // Screens list
  List<Widget> get _screens => const [
    RepaintBoundary(child: HomeScreen()),
    RepaintBoundary(child: ExploreScreen()),
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
    final theme = Theme.of(context);
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
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
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
