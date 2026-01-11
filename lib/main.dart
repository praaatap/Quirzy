import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'shared/services/cache_service.dart';
import 'shared/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical services
  await CacheService.init();
  await ReminderService.init();

  // Note: Appwrite is initialized lazily via singleton access in services

  runApp(const ProviderScope(child: QuirzyApp()));
}
