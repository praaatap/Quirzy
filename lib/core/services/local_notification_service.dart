import 'dart:math';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quirzy/core/constants/notification_messages.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _notificationIdStart = 1000;
  static const int _daysToSchedule = 7; // Schedule for next 7 days

  static Future<void> init() async {
    try {
      // 1. Initialize Timezones
      tz.initializeTimeZones();
      final String timeZoneName = tz.local.name;
      debugPrint('Timezone initialized: $timeZoneName');

      // 2. Initialize Plugin Settings
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
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Local Notification Tapped: ${details.payload}');
        },
      );

      // 3. Request Permissions (Android 13+)
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      // 4. Schedule Notifications
      await _scheduleUpcomingNotifications();
    } catch (e) {
      debugPrint('Error initializing LocalNotificationService: $e');
    }
  }

  static Future<void> _scheduleUpcomingNotifications() async {
    // Cancel previously scheduled reminders to update content/avoid duplicates
    await _cancelAllReminders();

    final random = Random();
    final times = [
      const TimeOfDay(hour: 9, minute: 0), // Morning
      const TimeOfDay(hour: 14, minute: 0), // Afternoon
      const TimeOfDay(hour: 20, minute: 0), // Evening
    ];

    for (int day = 0; day < _daysToSchedule; day++) {
      final date = DateTime.now().add(Duration(days: day));

      for (int i = 0; i < times.length; i++) {
        final time = times[i];

        // Pick random message
        final message = NotificationMessages
            .messages[random.nextInt(NotificationMessages.messages.length)];

        // Calculate TZDateTime
        var scheduledDate = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // If time has passed for today, skip it (unless we want to schedule it for next year, but typically we just skip)
        // Correct logic: we schedule for today+day.
        // If day=0 (today) and time passed, it won't fire or might throw error if we don't check.
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          continue;
        }

        final int notificationId = _notificationIdStart + (day * 10) + i;

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          message['title'],
          message['body'],
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminders',
              'Daily Reminders',
              channelDescription: 'Daily study reminders and motivation',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(message['body']!),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        debugPrint(
          'Scheduled notification ($notificationId) for: $scheduledDate',
        );
      }
    }
  }

  static Future<void> _cancelAllReminders() async {
    // Cancel a range of IDs
    for (int day = 0; day < _daysToSchedule; day++) {
      for (int i = 0; i < 3; i++) {
        final int notificationId = _notificationIdStart + (day * 10) + i;
        await _notificationsPlugin.cancel(notificationId);
      }
    }
    // Also cancel old "daily" if existed
    await _notificationsPlugin.cancel(0);
  }
}
