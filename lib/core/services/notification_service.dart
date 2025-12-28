import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quirzy/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationProvider =
    StateNotifierProvider<NotificationService, NotificationState>((ref) {
      return NotificationService(ref);
    });

class NotificationState {
  final String? fcmToken;
  final bool isInitialized;
  final RemoteMessage? lastMessage;
  final List<RemoteMessage> notifications;
  final int unreadCount;

  NotificationState({
    this.fcmToken,
    this.isInitialized = false,
    this.lastMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    String? fcmToken,
    bool? isInitialized,
    RemoteMessage? lastMessage,
    List<RemoteMessage>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      fcmToken: fcmToken ?? this.fcmToken,
      isInitialized: isInitialized ?? this.isInitialized,
      lastMessage: lastMessage ?? this.lastMessage,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationService extends StateNotifier<NotificationState> {
  final Ref ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ✅ 1. Initialize Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _notificationsKey = 'saved_notifications';
  static const String _unreadCountKey = 'unread_count';

  NotificationService(this.ref) : super(NotificationState()) {
    _loadSavedNotifications();
  }

  Future<void> initialize() async {
    try {
      // ✅ 2. Setup Local Notifications (Android)
      // Ensure you have an app icon named 'ic_launcher' in android/app/src/main/res/mipmap-*/
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('🔔 Foreground notification tapped: ${details.payload}');
          // Handle navigation here if needed
        },
      );

      // ✅ 3. Create Notification Channel (Required for Android 8.0+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // ✅ 4. Request Permission from Firebase
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');

        // ✅ 5. Get & Save Token
        String? token = await _messaging.getToken();
        if (token != null) {
          debugPrint('📱 FCM Token: $token');
          state = state.copyWith(fcmToken: token, isInitialized: true);
          await sendTokenAfterLogin();
        }

        _messaging.onTokenRefresh.listen((newToken) async {
          debugPrint('🔄 FCM Token refreshed: $newToken');
          state = state.copyWith(fcmToken: newToken);
          await sendTokenAfterLogin();
        });

        // ✅ 6. Start Listening for Messages (Pass the channel)
        _setupMessageHandlers(channel);
      } else {
        debugPrint('❌ User declined notification permission');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  void _setupMessageHandlers(AndroidNotificationChannel channel) {
    // A. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground Message: ${message.messageId}');

      // Update internal state
      final updatedNotifications = [message, ...state.notifications];
      state = state.copyWith(
        lastMessage: message,
        notifications: updatedNotifications,
        unreadCount: state.unreadCount + 1,
      );
      _saveNotifications();

      // ✅ B. TRIGGER THE VISUAL POP-UP
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              // importance and priority must be high for heads-up display
              importance: Importance.max,
              priority: Priority.high,
              color: Colors.deepPurple,
            ),
          ),
          payload: json.encode(message.data),
        );
      }

      _handleNotification(message);
    });

    // C. Background Tap Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification clicked (background): ${message.messageId}');
      _handleNotificationTap(message);
    });

    // D. Terminated Tap Handler
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
          '🔔 Notification clicked (terminated): ${message.messageId}',
        );
        _handleNotificationTap(message);
      }
    });
  }

  // --- HELPER METHODS ---

  Future<void> sendTokenAfterLogin() async {
    if (state.fcmToken == null) return;
    final authToken = await ApiService.getToken();
    if (authToken != null && authToken.isNotEmpty) {
      try {
        await ApiService.saveFcmToken(state.fcmToken!, authToken);
        debugPrint('✅ FCM token sent to backend via ApiService');
      } catch (e) {
        debugPrint('❌ Failed to send FCM token: $e');
      }
    }
  }

  Future<void> _loadSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getStringList(_notificationsKey) ?? [];
      final unreadCount = prefs.getInt(_unreadCountKey) ?? 0;

      final notifications = savedData.map((jsonStr) {
        final data = json.decode(jsonStr);
        return RemoteMessage(
          messageId: data['messageId'],
          notification: data['notification'] != null
              ? RemoteNotification(
                  title: data['notification']['title'],
                  body: data['notification']['body'],
                )
              : null,
          data: Map<String, dynamic>.from(data['data'] ?? {}),
          sentTime: data['sentTime'] != null
              ? DateTime.parse(data['sentTime'])
              : null,
        );
      }).toList();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationData = state.notifications.map((message) {
        return json.encode({
          'messageId': message.messageId,
          'notification': message.notification != null
              ? {
                  'title': message.notification!.title,
                  'body': message.notification!.body,
                }
              : null,
          'data': message.data,
          'sentTime': message.sentTime?.toIso8601String(),
        });
      }).toList();

      await prefs.setStringList(_notificationsKey, notificationData);
      await prefs.setInt(_unreadCountKey, state.unreadCount);
    } catch (e) {
      debugPrint('❌ Error saving notifications: $e');
    }
  }

  void _handleNotification(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('Handling notification type: $type');
    // Add specific logic here if you need to update other providers
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final challengeId = message.data['challengeId'];
    debugPrint('📱 User tapped notification: $type (Challenge: $challengeId)');
    // Add Navigator logic here using a GlobalKey if needed
  }

  void markAsRead() {
    if (state.unreadCount > 0) {
      debugPrint('✅ Marking notifications as read');
      state = state.copyWith(unreadCount: 0);
      _saveNotifications();
    }
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < state.notifications.length) {
      final updatedNotifications = List<RemoteMessage>.from(
        state.notifications,
      );
      updatedNotifications.removeAt(index);
      state = state.copyWith(notifications: updatedNotifications);
      _saveNotifications();
    }
  }

  void clearAll() {
    state = state.copyWith(notifications: [], unreadCount: 0);
    _saveNotifications();
  }
}
