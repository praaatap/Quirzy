import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/auth/providers/auth_provider.dart';

/// Deep Link Service for handling OAuth callbacks and app links
class DeepLinkService {
  static DeepLinkService? _instance;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  WidgetRef? _ref;

  DeepLinkService._() {
    _appLinks = AppLinks();
  }

  static DeepLinkService get instance {
    _instance ??= DeepLinkService._();
    return _instance!;
  }

  /// Initialize deep link handling with Riverpod ref
  Future<void> init(WidgetRef ref) async {
    _ref = ref;

    // Handle initial link (app opened via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('DeepLink: Initial link received: $initialUri');
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLink: Error getting initial link: $e');
    }

    // Listen for incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        debugPrint('DeepLink: Incoming link: $uri');
        await _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('DeepLink: Link stream error: $err');
      },
    );
  }

  /// Handle incoming deep links
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('DeepLink: Handling URI: $uri');
    debugPrint('DeepLink: Scheme: ${uri.scheme}');
    debugPrint('DeepLink: Host: ${uri.host}');
    debugPrint('DeepLink: Path: ${uri.path}');

    // Check if it's an Appwrite OAuth callback
    if (uri.scheme.startsWith('appwrite-callback')) {
      debugPrint('DeepLink: OAuth callback detected');
      await _handleOAuthCallback(uri);
    }
  }

  /// Handle OAuth callback from Appwrite (legacy - kept for backwards compatibility)
  /// Note: We now use native Google Sign-In, so OAuth callbacks are mostly ignored
  Future<void> _handleOAuthCallback(Uri uri) async {
    debugPrint('DeepLink: OAuth callback received (legacy handler)');
    debugPrint(
      'DeepLink: Note - Using native Google Sign-In, OAuth callbacks are handled differently',
    );

    // If somehow we receive an OAuth callback, try to refresh auth state
    if (_ref != null) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ref!.read(authProvider.notifier).refresh();
        debugPrint('DeepLink: Auth state refreshed');
      } catch (e) {
        debugPrint('DeepLink: Refresh failed: $e');
      }
    }
  }

  /// Dispose of subscriptions
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

/// Provider for DeepLinkService
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService.instance;
});
