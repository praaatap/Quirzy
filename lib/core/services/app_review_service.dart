import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Review Service - Smart review prompting for better ratings
///
/// Conditions for showing review prompt:
/// - User has completed at least 3 quizzes
/// - User has been using app for at least 3 days
/// - User has not been prompted in last 30 days
/// - User hasn't already rated the app
class AppReviewService {
  static final AppReviewService _instance = AppReviewService._internal();
  factory AppReviewService() => _instance;
  AppReviewService._internal();

  Box? _box;
  final InAppReview _inAppReview = InAppReview.instance;

  // Keys
  static const String _firstOpenKey = 'first_open_date';
  static const String _quizCompletedKey = 'quizzes_completed_count';
  static const String _lastPromptKey = 'last_review_prompt_date';
  static const String _hasRatedKey = 'has_rated';
  static const String _promptCountKey = 'review_prompt_count';

  // Play Store URL
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ps9labs.quirzy';

  /// Initialize the service
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('app_review');

    // Record first open date if not set
    if (_box!.get(_firstOpenKey) == null) {
      await _box!.put(_firstOpenKey, DateTime.now().toIso8601String());
    }

    debugPrint('⭐ App Review Service initialized');
  }

  /// Record quiz completion
  Future<void> recordQuizCompleted() async {
    if (_box == null) await initialize();
    final count = _box!.get(_quizCompletedKey, defaultValue: 0);
    await _box!.put(_quizCompletedKey, count + 1);
    debugPrint('📊 Quiz completed count: ${count + 1}');
  }

  /// Get quiz completion count
  int getQuizCompletedCount() {
    if (_box == null) return 0;
    return _box!.get(_quizCompletedKey, defaultValue: 0);
  }

  /// Check if should show review prompt
  bool shouldShowReviewPrompt() {
    if (_box == null) return false;

    // Already rated
    if (_box!.get(_hasRatedKey, defaultValue: false)) {
      return false;
    }

    // Check quiz count (at least 3)
    final quizCount = _box!.get(_quizCompletedKey, defaultValue: 0);
    if (quizCount < 3) return false;

    // Check days since first open (at least 3 days)
    final firstOpenStr = _box!.get(_firstOpenKey);
    if (firstOpenStr != null) {
      final firstOpen = DateTime.parse(firstOpenStr);
      final daysSinceFirstOpen = DateTime.now().difference(firstOpen).inDays;
      if (daysSinceFirstOpen < 3) return false;
    }

    // Check last prompt (at least 30 days ago)
    final lastPromptStr = _box!.get(_lastPromptKey);
    if (lastPromptStr != null) {
      final lastPrompt = DateTime.parse(lastPromptStr);
      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;
      if (daysSinceLastPrompt < 30) return false;
    }

    // Don't show more than 3 times total
    final promptCount = _box!.get(_promptCountKey, defaultValue: 0);
    if (promptCount >= 3) return false;

    return true;
  }

  /// Request review using in-app review
  Future<bool> requestReview() async {
    if (_box == null) await initialize();

    try {
      // Record prompt
      await _box!.put(_lastPromptKey, DateTime.now().toIso8601String());
      final promptCount = _box!.get(_promptCountKey, defaultValue: 0);
      await _box!.put(_promptCountKey, promptCount + 1);

      // Check if in-app review is available
      final isAvailable = await _inAppReview.isAvailable();
      debugPrint('⭐ In-app review available: $isAvailable');

      if (isAvailable) {
        await _inAppReview.requestReview();
        // Note: We can't know if user actually reviewed,
        // but we mark as prompted
        debugPrint('⭐ Review dialog requested');
        return true;
      } else {
        // Fallback to store listing
        debugPrint('⭐ Opening store listing as fallback');
        await openStoreListing();
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error requesting review: $e');
      return false;
    }
  }

  /// Open store listing directly
  Future<bool> openStoreListing() async {
    try {
      // Try in-app review's store listing first
      await _inAppReview.openStoreListing(appStoreId: 'com.ps9labs.quirzy');
      return true;
    } catch (e) {
      // Fallback to URL launcher
      try {
        final uri = Uri.parse(playStoreUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e2) {
        debugPrint('❌ Error opening store: $e2');
      }
      return false;
    }
  }

  /// Mark as rated (called when user says they've rated)
  Future<void> markAsRated() async {
    if (_box == null) await initialize();
    await _box!.put(_hasRatedKey, true);
    debugPrint('⭐ App marked as rated');
  }

  /// Show custom review dialog with options
  static Future<void> showReviewDialog(BuildContext context) async {
    final service = AppReviewService();
    await service.initialize();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Stars emoji
            const Text('⭐️⭐️⭐️⭐️⭐️', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 16),

            // Title
            Text(
              'Enjoying Quirzy?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Your feedback helps us improve! Would you mind rating us on the Play Store?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // Rate Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await service.requestReview();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B13EC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Rate Now ⭐',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Maybe Later button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),

            // Already rated button
            TextButton(
              onPressed: () async {
                await service.markAsRated();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thanks for rating us! 🎉'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: Text(
                'I\'ve Already Rated',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check and show review prompt automatically
  Future<void> checkAndShowReviewPrompt(BuildContext context) async {
    if (shouldShowReviewPrompt()) {
      // Delay slightly to not interrupt user
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        await showReviewDialog(context);
      }
    }
  }
}
