import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../auth/providers/auth_provider.dart';
import '../shared/widgets/splash_screen.dart';

// Screens
import '../auth/screens/welcome_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/signup_screen.dart';
import '../auth/screens/success_screen.dart';
import '../home/screens/main_screen.dart';
import '../quiz/screens/start_quiz_screen.dart';
import '../flashcards/screens/flashcards_screen.dart';
import '../profile/screens/history_screen.dart'; // Placeholder created
import '../profile/screens/settings_screen.dart'; // Placeholder created
import '../profile/screens/profile_screen.dart';
import '../profile/screens/api_key_settings_screen.dart';

class AuthListenator extends ChangeNotifier {
  AuthListenator(this.ref) {
    ref.listen<AsyncValue<dynamic>>(authProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.initial,
    debugLogDiagnostics: true,
    refreshListenable: AuthListenator(ref),
    redirect: (context, state) {
      final authState = ref.watch(authProvider);

      final isLoggedIn = authState.value != null;
      final isLoggingIn =
          state.matchedLocation == AppRoutes.auth ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.success;

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn) return AppRoutes.auth;
      if (isLoggedIn && isLoggingIn) return AppRoutes.home;
      if (isLoggedIn && state.matchedLocation == AppRoutes.initial)
        return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.success,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SuccessScreen(
            onComplete: () => context.go(AppRoutes.home),
            message: extra?['message'] ?? 'Success!',
            subtitle: extra?['subtitle'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return StartQuizScreen(
            quizTitle: extra?['quizTitle'] ?? 'Quiz',
            quizId: extra?['quizId'] ?? '',
            questions:
                (extra?['questions'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [],
            difficulty: extra?['difficulty'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.flashcards,
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.apiKeySettings,
        builder: (context, state) => const ApiKeySettingsScreen(),
      ),
    ],
  );
});
