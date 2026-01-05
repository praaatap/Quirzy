import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to manage daily usage limits for quizzes and flashcards
/// - Flashcards: 53 free generations per user per day
/// - Quizzes: 2 free quizzes per user per day
class DailyLimitService {
  static final DailyLimitService _instance = DailyLimitService._internal();
  factory DailyLimitService() => _instance;
  DailyLimitService._internal();

  Box? _box;

  // Daily limits
  static const int flashcardDailyLimit = 4;
  static const int quizDailyLimit = 2;

  // Keys for Hive storage
  static const String _flashcardCountKey = 'flashcard_daily_count';
  static const String _quizCountKey = 'quiz_daily_count';
  static const String _lastResetDateKey = 'last_reset_date';

  /// Initialize the service
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('daily_limits');
    await _checkAndResetDaily();
  }

  /// Check if we need to reset daily counts (new day)
  Future<void> _checkAndResetDaily() async {
    if (_box == null) return;

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final lastResetDate = _box!.get(_lastResetDateKey, defaultValue: '');

    if (lastResetDate != todayStr) {
      // New day - reset all counts
      await _box!.put(_flashcardCountKey, 0);
      await _box!.put(_quizCountKey, 0);
      await _box!.put(_lastResetDateKey, todayStr);
      debugPrint('🔄 Daily limits reset for new day: $todayStr');
    }
  }

  // ==========================================
  // FLASHCARD LIMITS (53 per day)
  // ==========================================

  /// Get current flashcard generation count for today
  int getFlashcardCount() {
    if (_box == null) return 0;
    _checkAndResetDaily();
    return _box!.get(_flashcardCountKey, defaultValue: 0);
  }

  /// Get remaining free flashcard generations for today
  int getRemainingFreeFlashcards() {
    final count = getFlashcardCount();
    final remaining = flashcardDailyLimit - count;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if flashcard limit is reached for today
  bool isFlashcardLimitReached() {
    return getFlashcardCount() >= flashcardDailyLimit;
  }

  /// Increment flashcard generation count
  Future<void> incrementFlashcardCount() async {
    if (_box == null) return;
    await _checkAndResetDaily();
    final current = _box!.get(_flashcardCountKey, defaultValue: 0);
    await _box!.put(_flashcardCountKey, current + 1);
    debugPrint('📚 Flashcard count: ${current + 1}/$flashcardDailyLimit');
  }

  // ==========================================
  // QUIZ LIMITS (2 per day)
  // ==========================================

  /// Get current quiz count for today
  int getQuizCount() {
    if (_box == null) return 0;
    _checkAndResetDaily();
    return _box!.get(_quizCountKey, defaultValue: 0);
  }

  /// Get remaining free quizzes for today
  int getRemainingFreeQuizzes() {
    final count = getQuizCount();
    final remaining = quizDailyLimit - count;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if quiz limit is reached for today
  bool isQuizLimitReached() {
    return getQuizCount() >= quizDailyLimit;
  }

  /// Increment quiz count
  Future<void> incrementQuizCount() async {
    if (_box == null) return;
    await _checkAndResetDaily();
    final current = _box!.get(_quizCountKey, defaultValue: 0);
    await _box!.put(_quizCountKey, current + 1);
    debugPrint('🎯 Quiz count: ${current + 1}/$quizDailyLimit');
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Get a summary of today's usage
  Map<String, dynamic> getDailyUsageSummary() {
    return {
      'flashcards': {
        'used': getFlashcardCount(),
        'limit': flashcardDailyLimit,
        'remaining': getRemainingFreeFlashcards(),
        'isLimitReached': isFlashcardLimitReached(),
      },
      'quizzes': {
        'used': getQuizCount(),
        'limit': quizDailyLimit,
        'remaining': getRemainingFreeQuizzes(),
        'isLimitReached': isQuizLimitReached(),
      },
    };
  }
}
