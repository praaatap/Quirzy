import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/connection_provider.dart';
import 'package:quirzy/shared/widgets/connectivity/no_internet_screen.dart';
import 'package:quirzy/features/auth/screens/welcome_screen.dart';
import 'package:quirzy/features/home/screens/main_screen.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/service/ad_service.dart';
import 'package:quirzy/core/storage/hive_cache_service.dart';
import 'package:quirzy/theme/theme.dart';
import 'package:quirzy/shared/widgets/loading/loading_screen.dart';
import 'package:showcaseview/showcaseview.dart';

// ==========================================
// PRODUCTION-OPTIMIZED MAIN.DART
// ==========================================
// Optimizations:
// - Parallel initialization for faster startup
// - Error boundaries for stability
// - Memory-efficient provider management
// - Deferred loading for non-critical services

Future<void> main() async {
  // Catch global errors for production stability
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In production, log to crash reporting service
      debugPrint('Flutter Error: ${details.exceptionAsString()}');
    }
  };

  WidgetsFlutterBinding.ensureInitialized();

  // System UI setup
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Optimize image cache for better memory usage
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 * 1024 * 1024; // 100MB
  PaintingBinding.instance.imageCache.maximumSize = 200; // max 200 images

  final container = ProviderContainer();
  final startTime = DateTime.now();

  try {
    // PHASE 1: Critical initialization (parallel)
    await Future.wait([Hive.initFlutter(), Firebase.initializeApp()]);

    // PHASE 2: App-critical services (parallel)
    await Future.wait([
      container.read(authProvider.notifier).initializeAuth(),
      HiveCacheService.initialize(),
    ]);

    // PHASE 3: Non-blocking services (fire and forget)
    Future.microtask(() async {
      try {
        await AdService().initialize();
        container.read(notificationProvider.notifier).initialize();
      } catch (e) {
        debugPrint('⚠️ Non-critical init error: $e');
      }
    });

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('✅ App initialized in ${elapsed}ms');

    // Minimum splash time for UX
    if (elapsed < 300) {
      await Future.delayed(Duration(milliseconds: 300 - elapsed));
    }
  } catch (e) {
    debugPrint('❌ Critical initialization error: $e');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const QuirzyApp()),
  );
}

// ==========================================
// OPTIMIZED APP WIDGET
// ==========================================

class QuirzyApp extends StatelessWidget {
  const QuirzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quirzy',

      // Theme configuration
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,

      // Performance: Reduce rebuilds with const builder
      builder: (context, child) {
        // Error boundary wrapper
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ProductionErrorWidget(details: details);
        };

        return MediaQuery(
          // Prevent text scaling issues
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: Stack(
            children: [
              ShowCaseWidget(builder: (context) => child!),
              const GlobalInternetOverlay(),
            ],
          ),
        );
      },

      home: const AuthWrapperOrSplash(),
    );
  }
}

// ==========================================
// AUTH WRAPPER (Optimized)
// ==========================================

class AuthWrapperOrSplash extends ConsumerWidget {
  const AuthWrapperOrSplash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select for minimal rebuilds
    final isInitialized = ref.watch(
      authProvider.select((s) => s.isInitialized),
    );
    final isLoggedIn = ref.watch(authProvider.select((s) => s.isLoggedIn));

    if (!isInitialized) {
      return const SplashScreen();
    }

    return isLoggedIn ? const MainScreen() : const QuiryHome();
  }
}

// ==========================================
// GLOBAL INTERNET OVERLAY (Optimized)
// ==========================================

class GlobalInternetOverlay extends ConsumerWidget {
  const GlobalInternetOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);

    return connectionState.when(
      data: (hasConnection) {
        if (!hasConnection) {
          return Positioned.fill(
            child: NoInternetScreen(
              onRetry: () => ref.invalidate(connectionProvider),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ==========================================
// PRODUCTION ERROR WIDGET
// ==========================================

class _ProductionErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _ProductionErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    // In release mode, show user-friendly error
    if (kReleaseMode) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // In debug mode, show error details
    return ErrorWidget(details.exception);
  }
}
