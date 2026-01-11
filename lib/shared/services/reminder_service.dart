import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';

/// Study Reminder Service
/// Manages daily study notifications
class ReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notifications
  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  /// Schedule daily study reminder
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await init();

    // Cancel existing reminder
    await cancelReminder();

    // Save reminder settings
    final box = Hive.box('settings_cache');
    await box.put('reminder_enabled', true);
    await box.put('reminder_hour', hour);
    await box.put('reminder_minute', minute);

    // Schedule new reminder
    await _notifications.zonedSchedule(
      1, // Notification ID
      '📚 Time to Study!',
      'Keep your streak going! Complete a quiz or review flashcards.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminder',
          'Study Reminders',
          channelDescription: 'Daily study reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel study reminder
  static Future<void> cancelReminder() async {
    await init();
    await _notifications.cancel(1);

    final box = Hive.box('settings_cache');
    await box.put('reminder_enabled', false);
  }

  /// Check if reminder is enabled
  static bool isReminderEnabled() {
    final box = Hive.box('settings_cache');
    return box.get('reminder_enabled', defaultValue: false) ?? false;
  }

  /// Get reminder time
  static (int, int)? getReminderTime() {
    final box = Hive.box('settings_cache');
    final hour = box.get('reminder_hour');
    final minute = box.get('reminder_minute');
    if (hour == null || minute == null) return null;
    return (hour as int, minute as int);
  }

  /// Show instant notification (for achievements, etc.)
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await init();
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Get next instance of specific time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
