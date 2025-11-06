import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/screen/mainPage/homeScreen.dart';
import 'package:quirzy/screen/mainPage/notification_screen.dart';
import 'package:quirzy/screen/mainPage/versus/versusPage.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(tabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomeScreen(), VersusPage(), NotificationScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            ref.read(tabIndexProvider.notifier).state = index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: isDark ? Colors.white : Colors.black,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.emoji_events,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.emoji_events_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            label: "Versus",
          ),
          NavigationDestination(
            // Add this new destination
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.notifications,
              color: isDark ? Colors.white : Colors.black,
            ),
            label: "Notifications",
          ),
        ],
        indicatorColor: isDark
            ? Colors.blueAccent
            : Colors.blue.shade800.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontWeight: FontWeight.normal,
          );
        }),
      ),
    );
  }
}
