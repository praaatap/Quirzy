// Basic Flutter widget test for Quirzy app
//
// Tests basic app startup and widget rendering

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quirzy/app.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: QuirzyApp()));

    // Verify that the app starts (splash screen or main content loads)
    await tester.pump(const Duration(milliseconds: 500));

    // Basic smoke test - app should render something
    expect(find.byType(QuirzyApp), findsOneWidget);
  });
}
