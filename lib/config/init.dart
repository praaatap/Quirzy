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
import 'package:quirzy/core/services/smart_notification_service.dart';
import 'package:quirzy/core/services/deep_link_service.dart';
import 'package:quirzy/core/services/daily_streak_service.dart';
import 'package:quirzy/core/services/rank_service.dart';

/// Stores pending rank-up result to show animation after app loads
RankUpResult? pendingRankUpResult;

Future<void> initializeApp(WidgetRef ref) async {
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
    [ref.read(authProvider.future), HiveCacheService.initialize()]
        as Iterable<Future<dynamic>>,
  );

  // Background Tasks
  Future.microtask(() => AdService().initialize());
  Future.microtask(() => ref.read(notificationProvider.notifier).initialize());

  // Initialize Deep Linking
  DeepLinkService.init();

  // Initialize Smart Notifications (2.5 hour intervals, quiet hours 12AM-6AM)
  Future.microtask(() async {
    await SmartNotificationService().init();
    // Schedule streak reminder at 8 PM
    await SmartNotificationService().scheduleStreakReminder(
      hour: 20,
      minute: 0,
    );
  });

  // Initialize Rank Service
  await RankService().initialize();

  // Daily Streak Tracking - Record login and award XP to rank system
  Future.microtask(() async {
    await DailyStreakService().initialize();
    final xpEarned = await DailyStreakService().recordLogin();

    if (xpEarned > 0) {
      debugPrint('🔥 Daily login streak! Earned $xpEarned XP');

      // Add XP to rank system
      final rankUpResult = await RankService().addXP(xpEarned);

      if (rankUpResult != null) {
        debugPrint(
          '🎉 RANK UP! ${rankUpResult.previousRank.name} → ${rankUpResult.newRank.name}',
        );
        // Store for showing animation later
        pendingRankUpResult = rankUpResult;
      }
    }

    // Record user activity for peak time tracking
    SmartNotificationService().recordUserActivity();
  });
}
