import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/features/auth/screens/welcome_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/shared/widgets/loading/loading_screen.dart';

/// Routes users to appropriate screen based on authentication state
class AuthRouter extends ConsumerWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitialized = ref.watch(
      authProvider.select((state) => state.isInitialized),
    );
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    if (!isInitialized) {
      return const SplashScreen();
    }

    return isLoggedIn ? const MainScreen() : const QuiryHome();
  }
}
