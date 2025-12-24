import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:quirzy/core/storage/hive_cache_service.dart';
import 'package:quirzy/theme/theme.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/service/ad_service.dart';
import 'package:quirzy/shared/widgets/app/app_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) debugPrint('Error: ${details.exceptionAsString()}');
  };

  // System UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Image cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 200;

  // Initialize services
  final container = ProviderContainer();

  try {
    await Future.wait([Hive.initFlutter(), Firebase.initializeApp()]);
    await Future.wait([
      container.read(authProvider.notifier).initializeAuth(),
      HiveCacheService.initialize(),
    ]);

    // Non-critical services
    Future.microtask(() async {
      try {
        await AdService().initialize();
        container.read(notificationProvider.notifier).initialize();
      } catch (_) {}
    });
  } catch (e) {
    debugPrint('Init error: $e');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const QuirzyApp()),
  );
}

class QuirzyApp extends StatelessWidget {
  const QuirzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quirzy',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        ErrorWidget.builder = (details) =>
            ProductionErrorWidget(details: details);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: Stack(
            children: [
              ShowCaseWidget(builder: (context) => child!),
              const ConnectivityOverlay(),
            ],
          ),
        );
      },
      home: const AuthRouter(),
    );
  }
}
