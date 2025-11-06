import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/theme_provider.dart';
import 'package:quirzy/screen/introduction/onboarding.dart';
import 'package:quirzy/screen/introduction/signIn.dart';
import 'package:quirzy/screen/introduction/signup.dart';
import 'package:quirzy/screen/introduction/welcome.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quirzy/utils/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasBeenOnboarded = prefs.getBool(kOnbordingStatus) ?? false;
  runApp(ProviderScope(child: MyApp(showOnboarding: hasBeenOnboarded)));
}

class MyApp extends ConsumerWidget {
final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode;

    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(isDarkMode: false),
      darkTheme: buildAppTheme(isDarkMode: true),
      themeMode: themeNotifier.themeMode,
      home: SignUpPage(), 
      // home: _buildHomeScreen(authState, showOnboarding),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
  }

  Widget _buildHomeScreen(AuthState authState, bool showOnboarding) {
    if (authState.user != null) {
      return const MainScreen();
    }
    else if (!showOnboarding) {
      return OnboardingScreen();
    }
    else {
      return const QuiryHome();
    }
  }