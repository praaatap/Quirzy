import 'package:hive_flutter/hive_flutter.dart';

/// Offline Cache Service using Hive
/// Caches quizzes and flashcards for offline use
class CacheService {
  static const String quizBox = 'quiz_cache';
  static const String flashcardBox = 'flashcard_cache';
  static const String settingsBox = 'settings_cache';
  static const String achievementsBox = 'achievements';

  static bool _initialized = false;

  /// Initialize Hive boxes
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<Map>(quizBox);
    await Hive.openBox<Map>(flashcardBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox<Map>(achievementsBox);
    _initialized = true;
  }

  // ==================== QUIZ CACHE ====================

  /// Cache a quiz for offline use
  static Future<void> cacheQuiz(
    String quizId,
    Map<String, dynamic> quiz,
  ) async {
    final box = Hive.box<Map>(quizBox);
    await box.put(quizId, quiz);
  }

  /// Get cached quiz
  static Map<String, dynamic>? getCachedQuiz(String quizId) {
    final box = Hive.box<Map>(quizBox);
    final data = box.get(quizId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all cached quizzes
  static List<Map<String, dynamic>> getAllCachedQuizzes() {
    final box = Hive.box<Map>(quizBox);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Remove cached quiz
  static Future<void> removeCachedQuiz(String quizId) async {
    final box = Hive.box<Map>(quizBox);
    await box.delete(quizId);
  }

  /// Clear all quiz cache
  static Future<void> clearQuizCache() async {
    final box = Hive.box<Map>(quizBox);
    await box.clear();
  }

  // ==================== FLASHCARD CACHE ====================

  /// Cache flashcard set
  static Future<void> cacheFlashcardSet(
    String setId,
    Map<String, dynamic> set,
  ) async {
    final box = Hive.box<Map>(flashcardBox);
    await box.put(setId, set);
  }

  /// Get cached flashcard set
  static Map<String, dynamic>? getCachedFlashcardSet(String setId) {
    final box = Hive.box<Map>(flashcardBox);
    final data = box.get(setId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all cached flashcard sets
  static List<Map<String, dynamic>> getAllCachedFlashcardSets() {
    final box = Hive.box<Map>(flashcardBox);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ==================== SETTINGS CACHE ====================

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await box.put(key, value);
  }

  /// Get setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  // ==================== STUDY STREAK ====================

  /// Get current study streak
  static int getStudyStreak() {
    return getSetting<int>('study_streak', defaultValue: 0) ?? 0;
  }

  /// Update study streak
  static Future<void> updateStudyStreak() async {
    final lastStudyDate = getSetting<String>('last_study_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastStudyDate == null) {
      await saveSetting('study_streak', 1);
    } else {
      final lastDate = DateTime.parse(lastStudyDate);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // Consecutive day - increase streak
        final currentStreak = getStudyStreak();
        await saveSetting('study_streak', currentStreak + 1);
      } else if (difference > 1) {
        // Streak broken - reset
        await saveSetting('study_streak', 1);
      }
      // Same day - do nothing
    }

    await saveSetting('last_study_date', today);
  }
}
