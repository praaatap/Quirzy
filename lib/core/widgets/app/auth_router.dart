import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/core/widgets/loading/splash_screen.dart';

/// Routes users to appropriate screen based on authentication state
/// Uses Consumer for selective rebuilds - better performance
class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Only watch the specific values we need for better performance
        final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
        final isLoggedIn = ref.watch(
          authProvider.select((s) => s.value != null),
        );

        // Determine which screen to show
        Widget child;
        if (isLoading) {
          child = const SplashScreen(key: ValueKey('splash'));
        } else if (isLoggedIn) {
          child = const MainScreen(key: ValueKey('main'));
        } else {
          child = const QuiryHome(key: ValueKey('welcome'));
        }

        // Smooth fade transition between screens
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: child,
        );
      },
    );
  }
}
