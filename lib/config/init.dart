import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';
import 'package:quirzy/core/services/ad_service.dart';
import 'package:quirzy/core/services/notification_service.dart';
import 'package:quirzy/core/services/storage/hive_cache_service.dart';
import 'package:quirzy/core/services/smart_notification_service.dart';
import 'package:quirzy/core/services/deep_link_service.dart';
import 'package:quirzy/core/services/daily_streak_service.dart';
import 'package:quirzy/core/services/rank_service.dart';
import 'package:quirzy/core/services/achievements_service.dart';
import 'package:quirzy/core/services/offline_quiz_manager.dart';
import 'package:quirzy/core/services/background_initializer.dart';
import 'package:quirzy/core/services/mistake_flashcard_service.dart';

/// Stores pending rank-up result to show animation after app loads
RankUpResult? pendingRankUpResult;

/// Critical initialization - runs during splash screen
/// Keep this as fast as possible
Future<void> initializeCriticalServices(WidgetRef ref) async {
  // System UI - instant
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

  // Critical services - must complete before home screen
  try {
    // Add 8s timeout to prevent infinite splash screen
    await Future.wait([
      Hive.initFlutter(),
      Firebase.initializeApp(),
    ]).timeout(const Duration(seconds: 8));

    await HiveCacheService.initialize();
  } catch (e) {
    debugPrint('⚠️ Critical init warning: $e');
    // Continue anyway - allow app to load even if Firebase/Hive fails partially
  }

  // Auth can run in parallel
  unawaited(ref.read(authProvider.future).catchError((_) => null));

  debugPrint('✅ Critical services initialized (or bypassed)');
}

/// Deferred initialization - runs AFTER home screen is visible
/// This prevents animation jank during splash to home transition
Future<void> initializeDeferredServices(WidgetRef ref) async {
  debugPrint('🚀 Starting deferred services...');

  // Schedule heavy work after frame completes and give UI time to settle
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Delay initialization to allow splash transition to complete smoothly
    await Future.delayed(const Duration(seconds: 1));
    // Initialize Deep Linking first (lightweight)
    DeepLinkService.init();

    // Rank Service (needed for UI)
    await RankService().initialize();

    // These can run in background without blocking UI
    _initializeBackgroundServices(ref);

    // Enable High Refresh Rate (120Hz) on Android
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Dynamic import workaround or just standard usage since package handles platform check?
        // flutter_displaymode is android only but safely handles calls usually.
        // But better to check platform.
        // We need to import package first
        await _setHighRefreshRate();
      }
    } catch (e) {
      debugPrint('⚠️ Refresh rate error: $e');
    }
  });
}

Future<void> _setHighRefreshRate() async {
  try {
    await FlutterDisplayMode.setHighRefreshRate();
    debugPrint('🚀 High Refresh Rate Enabled (120Hz/90Hz)');
  } catch (e) {
    debugPrint('⚠️ High Refresh Rate failed: $e');
  }
}

/// Background services - run completely in background
void _initializeBackgroundServices(WidgetRef ref) {
  // Use microtasks to spread work across frames
  Future.microtask(() => AdService().initialize());
  Future.microtask(() => ref.read(notificationProvider.notifier).initialize());
  Future.microtask(() => BackgroundInitializer().initializeDeferredServices());

  // Dependent services - initialize in order
  Future.microtask(() async {
    // 1. Initialize data providers
    await Future.wait([
      OfflineQuizManager().initialize(),
      MistakeFlashcardService().initialize(),
      AchievementsService().initialize(),
    ]);

    // 2. Initialize consumers (Notifications)
    await SmartNotificationService().init();
    await SmartNotificationService().scheduleStreakReminder(
      hour: 20,
      minute: 0,
    );
  });

  // Daily streak - runs last, may show animation
  Future.delayed(const Duration(milliseconds: 500), () async {
    await _handleDailyStreak();
  });
}

/// Handle daily streak and rank-up detection
Future<void> _handleDailyStreak() async {
  try {
    await DailyStreakService().initialize();
    final xpEarned = await DailyStreakService().recordLogin();

    if (xpEarned > 0) {
      debugPrint('🔥 Daily login streak! Earned $xpEarned XP');

      final rankUpResult = await RankService().addXP(xpEarned);

      if (rankUpResult != null) {
        debugPrint(
          '🎉 RANK UP! ${rankUpResult.previousRank.name} → ${rankUpResult.newRank.name}',
        );
        pendingRankUpResult = rankUpResult;
      }

      // Check streak achievements
      final currentStreak = DailyStreakService().getCurrentStreak();
      await AchievementsService().checkStreakAchievements(currentStreak);
    }

    // Record activity for smart notifications
    SmartNotificationService().recordUserActivity();
  } catch (e) {
    debugPrint('⚠️ Daily streak error: $e');
  }
}

/// Helper for running futures without awaiting
void unawaited(Future<void> future) {}

/// Legacy compatibility - calls both critical and deferred
@Deprecated(
  'Use initializeCriticalServices and initializeDeferredServices instead',
)
Future<void> initializeApp(WidgetRef ref) async {
  await initializeCriticalServices(ref);
  await initializeDeferredServices(ref);
}
