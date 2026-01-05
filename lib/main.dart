import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quirzy/app.dart';
import 'package:quirzy/config/init.dart';
import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/core/widgets/loading/splash_screen.dart';
import 'package:flutter/services.dart';

/// Global theme state loaded before app starts
/// This eliminates the theme flash on startup
ThemeMode? _initialThemeMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme preference BEFORE first frame renders
  await _loadInitialTheme();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ProviderScope(child: AppBootstrap()));
}

/// Load theme preference synchronously before app starts
Future<void> _loadInitialTheme() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final useSystemTheme =
        prefs.getBool('use_system_theme') ?? !prefs.containsKey('dark_mode');
    final darkMode = prefs.getBool('dark_mode') ?? false;

    if (useSystemTheme) {
      _initialThemeMode = ThemeMode.system;
    } else {
      _initialThemeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    }
  } catch (e) {
    // Fallback to system theme if loading fails
    _initialThemeMode = ThemeMode.system;
  }
}

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Perform initialization
    await initializeApp(ref);

    // Update state to show the main app
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the pre-loaded theme for splash screen (eliminates flash)
    final themeMode = _initialThemeMode ?? ThemeMode.system;

    if (!_isInitialized) {
      // Show Splash Screen with CORRECT theme from the start
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode, // Use pre-loaded theme
        home: const SplashScreen(),
      );
    }

    // Show Main App once initialized
    return const QuirzyApp();
  }
}
