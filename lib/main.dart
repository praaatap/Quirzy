import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/app.dart';
import 'package:quirzy/config/init.dart';
import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/core/widgets/loading/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppBootstrap()));
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
    if (!_isInitialized) {
      // Show Splash Screen while initializing
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      );
    }

    // Show Main App once initialized
    return const QuirzyApp();
  }
}
