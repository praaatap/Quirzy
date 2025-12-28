import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/core/widgets/loading/loading_screen.dart';

/// Routes users to appropriate screen based on authentication state
class AuthRouter extends ConsumerWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isInitialized = !authState.isLoading;
    final isLoggedIn = authState.value != null;

    if (!isInitialized) {
      return const SplashScreen();
    }

    return isLoggedIn ? const MainScreen() : const QuiryHome();
  }
}
