import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/app.dart';
import 'package:quirzy/config/init.dart';

void main() async {
  final container = ProviderContainer();

  // Initialize all services and configs
  await initializeApp(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const QuirzyApp()),
  );
}
