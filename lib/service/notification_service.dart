import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/service/api_service.dart';

// ==================== NOTIFICATION STATE ====================

class NotificationState {
  final String? fcmToken;
  final List<RemoteMessage> notifications;
  final int unreadCount;

  NotificationState({
    this.fcmToken,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    String? fcmToken,
    List<RemoteMessage>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      fcmToken: fcmToken ?? this.fcmToken,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// ==================== NOTIFICATION NOTIFIER ====================

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ========== INITIALIZE NOTIFICATIONS ==========
  Future<void> initialize() async {
    debugPrint('🔔 Initializing notification service...');

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('✅ Local notifications initialized');

    // Request FCM permission
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notification permission granted');

      // Get FCM token
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token: $token');
        state = state.copyWith(fcmToken: token);
      }

      // Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        state = state.copyWith(fcmToken: newToken);
      });

      // Listen to foreground messages (app is open)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to background message taps (app was in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Check if app was opened from terminated state by notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📲 App opened from terminated state by notification');
        _handleBackgroundMessageTap(initialMessage);
      }
    } else {
      debugPrint('❌ Notification permission denied');
    }
  }

  // ========== HANDLE FOREGROUND MESSAGES ==========
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Foreground message received: ${message.messageId}');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    // Add to notification list
    final updatedNotifications = [message, ...state.notifications];
    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: state.unreadCount + 1,
    );

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // ========== SHOW LOCAL NOTIFICATION ==========
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'challenge_channel',
        'Challenge Notifications',
        channelDescription: 'Notifications for 1v1 challenge invites and updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(data),
      );

      debugPrint('✅ Local notification shown');
    }
  }

  // ========== HANDLE NOTIFICATION TAP (FOREGROUND) ==========
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📲 Notification tapped (foreground): ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateBasedOnType(data);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  // ========== HANDLE BACKGROUND NOTIFICATION TAP ==========
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('📲 Background notification tapped');
    debugPrint('   Data: ${message.data}');

    _navigateBasedOnType(message.data);
  }

  // ========== NAVIGATE BASED ON NOTIFICATION TYPE ==========
  void _navigateBasedOnType(Map<String, dynamic> data) {
    final type = data['type'];
    final challengeId = data['challengeId'];
    final challengerName = data['challengerName'];
    final opponentName = data['opponentName'];

    debugPrint('🧭 Navigation requested for type: $type');

    switch (type) {
      case 'challenge_invite':
        debugPrint('🎯 Challenge invite received');
        debugPrint('   Challenge ID: $challengeId');
        debugPrint('   Challenger: $challengerName');
        // TODO: Navigate to challenge accept/reject screen
        // Example:
        // NavigationService.navigateTo(
        //   '/challenge/accept',
        //   arguments: {
        //     'challengeId': challengeId,
        //     'challengerName': challengerName,
        //   },
        // );
        break;

      case 'challenge_accepted':
        debugPrint('✅ Challenge accepted by opponent');
        debugPrint('   Challenge ID: $challengeId');
        debugPrint('   Opponent: $opponentName');
        // TODO: Navigate to quiz/battle screen
        // Example:
        // NavigationService.navigateTo(
        //   '/battle',
        //   arguments: {'challengeId': challengeId},
        // );
        break;

      case 'challenge_rejected':
        debugPrint('❌ Challenge rejected by opponent');
        debugPrint('   Challenge ID: $challengeId');
        // TODO: Show rejection message or navigate to home
        // Example:
        // NavigationService.navigateTo('/home');
        // showSnackbar('Challenge was rejected');
        break;

      default:
        debugPrint('❓ Unknown notification type: $type');
    }
  }

  // ========== SEND TOKEN TO BACKEND ==========
  Future<void> sendTokenToBackend(String? authToken) async {
    if (state.fcmToken == null || authToken == null) {
      debugPrint('⚠️ Cannot send token: FCM token or auth token missing');
      debugPrint('   FCM Token: ${state.fcmToken}');
      debugPrint('   Auth Token: ${authToken != null ? "present" : "null"}');
      return;
    }

    try {
      debugPrint('📤 Sending FCM token to backend...');
      await ApiService.saveFcmToken(state.fcmToken!, authToken);
      debugPrint('✅ FCM token sent to backend successfully');
    } catch (e) {
      debugPrint('❌ Failed to send FCM token to backend: $e');
    }
  }

  // ========== MARK NOTIFICATIONS AS READ ==========
  void markAsRead() {
    debugPrint('✅ Marking notifications as read');
    state = state.copyWith(unreadCount: 0);
  }

  // ========== CLEAR ALL NOTIFICATIONS ==========
  void clearAll() {
    debugPrint('🗑️ Clearing all notifications');
    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
    );
  }

  // ========== DELETE SINGLE NOTIFICATION ==========
  void deleteNotification(int index) {
    debugPrint('🗑️ Deleting notification at index: $index');
    final updated = List<RemoteMessage>.from(state.notifications);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(
        notifications: updated,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    }
  }

  // ========== GET UNREAD COUNT ==========
  int getUnreadCount() {
    return state.unreadCount;
  }
}

// ==================== PROVIDER ====================

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
