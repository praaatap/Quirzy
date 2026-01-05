import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quirzy/core/services/smart_notification_service.dart';

/// Deep Link Service for handling notification taps and external links
///
/// Supported deep links:
/// - quirzy://quiz - Opens quiz generation screen
/// - quirzy://flashcards - Opens flashcards screen
/// - quirzy://profile - Opens profile screen
/// - quirzy://rank - Opens rank progress (profile)
/// - quirzy://streak - Opens streak info (home)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// Global navigator key for navigation without context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Pending deep link to process after app is ready
  static String? _pendingDeepLink;

  /// Initialize deep link handling
  static void init() {
    // Set up notification tap handler
    SmartNotificationService.onNotificationTap = _handleNotificationPayload;
    debugPrint('🔗 Deep Link Service initialized');
  }

  /// Get pending deep link (if any)
  static String? get pendingDeepLink => _pendingDeepLink;

  /// Clear pending deep link after processing
  static void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  /// Handle notification payload for deep linking
  static void _handleNotificationPayload(String payload) {
    debugPrint('🔗 Processing deep link payload: $payload');

    // Store as pending if app is not ready yet
    if (navigatorKey.currentContext == null) {
      _pendingDeepLink = payload;
      debugPrint('⏳ Deep link stored as pending: $payload');
      return;
    }

    // Navigate immediately
    navigateToPayload(navigatorKey.currentContext!, payload);
  }

  /// Navigate to the appropriate screen based on payload
  static void navigateToPayload(BuildContext context, String payload) {
    debugPrint('🔗 Navigating to: $payload');

    switch (payload) {
      case SmartNotificationService.payloadQuiz:
        // Navigate to home with quiz generation dialog trigger
        context.go('/');
        // The home screen should detect this and show quiz dialog
        _showQuizDialogAfterNavigation(context);
        break;

      case SmartNotificationService.payloadFlashcards:
        // Navigate to flashcards screen
        context.go('/flashcards');
        break;

      case SmartNotificationService.payloadStreak:
      case SmartNotificationService.payloadRank:
        // Navigate to profile screen
        context.go('/profile');
        break;

      default:
        debugPrint('⚠️ Unknown deep link payload: $payload');
        context.go('/');
    }
  }

  /// Show quiz dialog after short delay (allows navigation to complete)
  static void _showQuizDialogAfterNavigation(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      // Dispatch event to show quiz dialog
      // This would be picked up by the home screen
      _notifyQuizDialogRequested();
    });
  }

  /// Callback for quiz dialog request
  static VoidCallback? onQuizDialogRequested;

  static void _notifyQuizDialogRequested() {
    onQuizDialogRequested?.call();
  }

  /// Process pending deep link (call this after app is initialized)
  static void processPendingDeepLink(BuildContext context) {
    if (_pendingDeepLink != null) {
      debugPrint('🔗 Processing pending deep link: $_pendingDeepLink');
      navigateToPayload(context, _pendingDeepLink!);
      clearPendingDeepLink();
    }
  }

  /// Parse URI deep link (for handling app links)
  static String? parseUri(Uri uri) {
    // Handle quirzy:// scheme
    if (uri.scheme == 'quirzy') {
      return uri.host;
    }

    // Handle https://quirzy.app/ scheme
    if (uri.host == 'quirzy.app' || uri.host == 'www.quirzy.app') {
      final path = uri.pathSegments.firstOrNull;
      return path;
    }

    return null;
  }
}
