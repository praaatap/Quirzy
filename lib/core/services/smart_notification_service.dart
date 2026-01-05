import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:quirzy/core/services/offline_quiz_manager.dart';
import 'package:quirzy/core/services/mistake_flashcard_service.dart';

/// Smart Notification Service for User Retention
///
/// Features:
/// - Sends notifications every 2.5 hours during active hours
/// - Respects quiet hours (12 AM - 6 AM)
/// - Tracks peak usage times and prioritizes those
/// - Supports deep linking to specific screens
/// - Gamification-focused messages
class SmartNotificationService {
  static final SmartNotificationService _instance =
      SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Box? _box;

  // Notification IDs
  static const int _streakReminderId = 2000;
  static const int _quizNotificationIdStart = 2100;
  static const int _flashcardNotificationIdStart = 2200;
  static const int _engagementNotificationIdStart = 2300;

  // Settings
  static const int _quietHourStart = 0; // 12 AM
  static const int _quietHourEnd = 6; // 6 AM
  static const double _notificationIntervalHours = 2.5;
  static const int _daysToSchedule = 7;

  // Deep link payloads
  static const String payloadQuiz = 'quiz';
  static const String payloadFlashcards = 'flashcards';
  static const String payloadStreak = 'streak';
  static const String payloadRank = 'rank';

  /// Callback for handling notification taps - set this in main.dart
  static Function(String payload)? onNotificationTap;

  /// Initialize the service
  Future<void> init() async {
    try {
      // Initialize Hive box for tracking
      _box = await Hive.openBox('notification_tracking');

      // Initialize Timezones
      tz.initializeTimeZones();
      debugPrint('🔔 Smart Notification Service initialized');

      // Initialize Plugin Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Request Permissions (Android 13+)
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      // Schedule smart notifications
      await scheduleSmartNotifications();
    } catch (e) {
      debugPrint('❌ Error initializing SmartNotificationService: $e');
    }
  }

  /// Handle notification tap for deep linking
  static void _handleNotificationTap(NotificationResponse details) {
    final payload = details.payload;
    debugPrint('🔔 Notification tapped with payload: $payload');

    if (payload != null && onNotificationTap != null) {
      onNotificationTap!(payload);
    }
  }

  /// Record user activity for peak time tracking
  Future<void> recordUserActivity() async {
    if (_box == null) return;

    final now = DateTime.now();
    final hourKey = 'activity_hour_${now.hour}';
    final currentCount = _box!.get(hourKey, defaultValue: 0);
    await _box!.put(hourKey, currentCount + 1);

    debugPrint('📊 Activity recorded at hour ${now.hour}');
  }

  /// Get peak activity hours based on user history
  List<int> _getPeakHours() {
    if (_box == null) return [9, 12, 15, 18, 21]; // Default peak hours

    final Map<int, int> hourCounts = {};
    for (int hour = 0; hour < 24; hour++) {
      final count = _box!.get('activity_hour_$hour', defaultValue: 0);
      hourCounts[hour] = count;
    }

    // Sort hours by activity count and get top 5
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final peakHours = sortedHours
        .take(5)
        .map((e) => e.key)
        .where((hour) => !_isQuietHour(hour))
        .toList();

    // If no data, return defaults
    if (peakHours.isEmpty) {
      return [9, 12, 15, 18, 21];
    }

    return peakHours;
  }

  /// Check if an hour is during quiet time (12 AM - 6 AM)
  bool _isQuietHour(int hour) {
    return hour >= _quietHourStart && hour < _quietHourEnd;
  }

  /// Schedule smart notifications for the week
  Future<void> scheduleSmartNotifications() async {
    await _cancelAllNotifications();

    final random = Random();
    final peakHours = _getPeakHours();

    debugPrint('📊 Peak hours detected: $peakHours');

    // Calculate notification times every 2.5 hours (excluding quiet hours)
    final notificationHours = <int>[];
    for (double hour = 6.0; hour < 24.0; hour += _notificationIntervalHours) {
      final roundedHour = hour.round();
      if (!_isQuietHour(roundedHour)) {
        notificationHours.add(roundedHour);
      }
    }

    debugPrint('🔔 Notification hours: $notificationHours');

    int notificationIndex = 0;

    for (int day = 0; day < _daysToSchedule; day++) {
      final date = DateTime.now().add(Duration(days: day));

      for (final hour in notificationHours) {
        // Add some randomness to minutes (0-30)
        final minute = random.nextInt(30);

        // Calculate scheduled time
        var scheduledDate = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Skip if time has passed
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          continue;
        }

        // Determine notification type based on time and randomness
        final NotificationContent content = _getSmartNotificationContent(
          hour: hour,
          isPeakHour: peakHours.contains(hour),
          random: random,
        );

        final int notificationId =
            _engagementNotificationIdStart + notificationIndex;
        notificationIndex++;

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          content.title,
          content.body,
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'smart_reminders',
              'Smart Study Reminders',
              channelDescription:
                  'Personalized study reminders based on your habits',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(content.body),
              category: AndroidNotificationCategory.reminder,
              color: const Color(0xFF5B13EC),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: content.payload,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        debugPrint(
          '✅ Scheduled: ${content.title} at $scheduledDate (ID: $notificationId)',
        );
      }
    }
  }

  /// Get smart notification content based on context
  NotificationContent _getSmartNotificationContent({
    required int hour,
    required bool isPeakHour,
    required Random random,
  }) {
    // Morning hours (6-12)
    if (hour >= 6 && hour < 12) {
      return _getMorningNotification(random, isPeakHour);
    }
    // Afternoon hours (12-18)
    else if (hour >= 12 && hour < 18) {
      return _getAfternoonNotification(random, isPeakHour);
    }
    // Evening hours (18-24)
    else {
      return _getEveningNotification(random, isPeakHour);
    }
  }

  NotificationContent _getMorningNotification(Random random, bool isPeakHour) {
    final messages = [
      NotificationContent(
        title: '☀️ Good Morning, Champion!',
        body:
            'Start your day with a quick quiz. Your brain is sharpest in the morning!',
        payload: payloadQuiz,
      ),
      NotificationContent(
        title: '🔥 Keep Your Streak Alive!',
        body:
            'Don\'t let your learning streak break. Take a 2-minute quiz now!',
        payload: payloadStreak,
      ),
      NotificationContent(
        title: '📚 Morning Flashcard Session',
        body:
            'Review your flashcards before the day gets busy. Just 5 minutes!',
        payload: payloadFlashcards,
      ),
      NotificationContent(
        title: '🎯 Rise & Quiz!',
        body:
            'Early learners score 20% higher. Start your learning journey now!',
        payload: payloadQuiz,
      ),
      NotificationContent(
        title: '⚡ Power Up Your Brain',
        body: 'Morning is the best time to learn. Create some new flashcards!',
        payload: payloadFlashcards,
      ),
    ];

    return messages[random.nextInt(messages.length)];
  }

  NotificationContent _getAfternoonNotification(
    Random random,
    bool isPeakHour,
  ) {
    final messages = [
      NotificationContent(
        title: '☕ Afternoon Brain Boost',
        body:
            'Beat the afternoon slump with a challenging quiz. You\'ve got this!',
        payload: payloadQuiz,
      ),
      NotificationContent(
        title: '🏆 Time to Rank Up!',
        body:
            'You\'re just a few XP away from your next rank. Take a quiz now!',
        payload: payloadRank,
      ),
      NotificationContent(
        title: '🃏 Quick Flashcard Review',
        body: 'Spaced repetition is the key to memory. Review your cards now!',
        payload: payloadFlashcards,
      ),
      NotificationContent(
        title: '💪 You\'re Doing Amazing!',
        body: 'Keep the momentum going. One more quiz can\'t hurt!',
        payload: payloadQuiz,
      ),
      NotificationContent(
        title: '🎮 Learning Break Time',
        body:
            'Take a productive break. Generate some flashcards on a new topic!',
        payload: payloadFlashcards,
      ),
    ];

    if (isPeakHour) {
      messages.add(
        NotificationContent(
          title: '📊 This is Your Peak Time!',
          body: 'You learn best at this hour. Make the most of it with a quiz!',
          payload: payloadQuiz,
        ),
      );
    }

    return messages[random.nextInt(messages.length)];
  }

  NotificationContent _getEveningNotification(Random random, bool isPeakHour) {
    final messages = [
      NotificationContent(
        title: '🌙 Evening Review Session',
        body: 'Wrap up your day by reinforcing what you learned. Quick quiz?',
        payload: payloadQuiz,
      ),
      NotificationContent(
        title: '🔥 Don\'t Break Your Streak!',
        body:
            'You still have time to keep your streak alive. One quiz does it!',
        payload: payloadStreak,
      ),
      NotificationContent(
        title: '✨ Relax & Learn',
        body: 'Wind down with some light flashcard review before bed.',
        payload: payloadFlashcards,
      ),
      NotificationContent(
        title: '📈 Check Your Progress',
        body:
            'See how much XP you\'ve earned today. You might be close to ranking up!',
        payload: payloadRank,
      ),
      NotificationContent(
        title: '🧠 Night Owl Learning',
        body: 'Some of the best learning happens at night. Take a quiz!',
        payload: payloadQuiz,
      ),
    ];

    return messages[random.nextInt(messages.length)];
  }

  /// Cancel all scheduled notifications
  Future<void> _cancelAllNotifications() async {
    // Cancel engagement notifications
    for (int i = 0; i < 200; i++) {
      await _notificationsPlugin.cancel(_engagementNotificationIdStart + i);
    }
    // Cancel streak reminder
    await _notificationsPlugin.cancel(_streakReminderId);
    // Cancel quiz notifications
    for (int i = 0; i < 50; i++) {
      await _notificationsPlugin.cancel(_quizNotificationIdStart + i);
    }
    // Cancel flashcard notifications
    for (int i = 0; i < 50; i++) {
      await _notificationsPlugin.cancel(_flashcardNotificationIdStart + i);
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      9999,
      '🧪 Test Notification',
      'This is a test notification with deep linking to quiz screen.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'For testing purposes',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFF5B13EC),
        ),
      ),
      payload: payloadQuiz,
    );
  }

  /// Schedule streak reminder for specific time
  Future<void> scheduleStreakReminder({int hour = 20, int minute = 0}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      _streakReminderId,
      '🔥 Don\'t Lose Your Streak!',
      'You haven\'t studied today yet. Keep your streak alive before midnight!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Reminders to maintain your learning streak',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          color: const Color(0xFFFF6B00),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payloadStreak,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('🔥 Streak reminder scheduled for $scheduledDate');
  }
}

/// Model for notification content with deep link payload
class NotificationContent {
  final String title;
  final String body;
  final String payload;

  const NotificationContent({
    required this.title,
    required this.body,
    required this.payload,
  });
}
