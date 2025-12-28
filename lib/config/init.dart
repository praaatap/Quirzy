import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/core/services/ad_service.dart';
import 'package:quirzy/core/services/notification_service.dart';
import 'package:quirzy/core/services/storage/hive_cache_service.dart';

Future<void> initializeApp(ProviderContainer container) async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI & Error Handling
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  FlutterError.onError = (details) {
    if (kReleaseMode) debugPrint('Error: ${details.exceptionAsString()}');
  };

  // Critical Services
  await Future.wait([Hive.initFlutter(), Firebase.initializeApp()]);
  await Future.wait(
    [container.read(authProvider.future), HiveCacheService.initialize()]
        as Iterable<Future<dynamic>>,
  );

  // Background Tasks
  Future.microtask(() => AdService().initialize());
  Future.microtask(
    () => container.read(notificationProvider.notifier).initialize(),
  );
}
