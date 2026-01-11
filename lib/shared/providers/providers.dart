import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/settings_service.dart';

/// Tab index provider for bottom navigation
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Notification notifier using ChangeNotifier pattern
class NotificationNotifier extends ChangeNotifier {
  Future<void> sendTokenAfterLogin() async {
    // Stub for FCM token sending
  }
}

/// Notification provider
final notificationProvider = ChangeNotifierProvider<NotificationNotifier>(
  (ref) => NotificationNotifier(),
);

/// Settings provider using ChangeNotifierProvider
final settingsProvider = ChangeNotifierProvider<SettingsService>(
  (ref) => SettingsService(),
);
