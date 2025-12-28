import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quirzy/routes/app_routes.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/routes/auth_listenator.dart';

// Screens
import 'package:quirzy/core/widgets/loading/loading_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/login_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/signup_screen.dart';
import 'package:quirzy/features/auth/presentation/screens/success_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/features/quiz/screens/start_quiz_screen.dart';
import 'package:quirzy/features/flashcards/screens/flashcards_screen.dart';
import 'package:quirzy/features/history/screens/history_screen.dart';
import 'package:quirzy/features/settings/presentation/screens/settings_screen.dart';
import 'package:quirzy/features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.initial,
    debugLogDiagnostics: true,
    refreshListenable: AuthListenator(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isLoggingIn =
          state.matchedLocation == AppRoutes.auth ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation ==
              AppRoutes.success; // Success is part of auth flow typically

      // 1. Not logged in -> Redirect to Auth (Welcome)
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.auth;
      }

      // 2. Logged in -> Redirect to Home if trying to access Auth pages
      // Exception: Success page might be shown after login, so don't redirect away from it immediately if we just got there.
      // But typically success page redirects to home itself.
      if (isLoggedIn &&
          (state.matchedLocation == AppRoutes.auth ||
              state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.signup)) {
        return AppRoutes.home;
      }

      // 3. Logged in and on Splash (initial) -> Home
      if (isLoggedIn && state.matchedLocation == AppRoutes.initial) {
        return AppRoutes.home;
      }

      // 4. Not logged in and on Splash -> Auth
      if (!isLoggedIn && state.matchedLocation == AppRoutes.initial) {
        return AppRoutes.auth;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const QuiryHome(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
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
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
