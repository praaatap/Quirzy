import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Offline Quiz Manager - Enables offline quiz playing
///
/// Features:
/// - Save quizzes for offline play
/// - Generate daily challenges offline
/// - Quick quiz from cached content
/// - Practice mode from history
class OfflineQuizManager {
  static final OfflineQuizManager _instance = OfflineQuizManager._internal();
  factory OfflineQuizManager() => _instance;
  OfflineQuizManager._internal();

  Box? _quizBox;
  Box? _dailyChallengeBox;
  final Random _random = Random();

  // Storage keys
  static const String _savedQuizzesKey = 'saved_quizzes';
  static const String _todaysChallengeKey = 'todays_challenge';
  static const String _challengeDateKey = 'challenge_date';
  static const String _challengeCompletedKey = 'challenge_completed';
  static const String _practiceQuestionsKey = 'practice_questions';

  /// Initialize
  Future<void> initialize() async {
    if (_quizBox != null) return;
    _quizBox = await Hive.openBox('offline_quizzes');
    _dailyChallengeBox = await Hive.openBox('daily_challenges');
    debugPrint('📴 Offline Quiz Manager initialized');
  }

  // ==========================================
  // SAVE QUIZ FOR OFFLINE
  // ==========================================

  /// Save a quiz for offline play
  Future<void> saveQuizForOffline({
    required String quizId,
    required String title,
    required List<Map<String, dynamic>> questions,
    String? difficulty,
  }) async {
    if (_quizBox == null) await initialize();

    final savedQuizzes = _getSavedQuizzes();

    // Remove if already exists and re-add (update)
    savedQuizzes.removeWhere((q) => q['id'] == quizId);

    savedQuizzes.add({
      'id': quizId,
      'title': title,
      'questions': questions,
      'difficulty': difficulty ?? 'medium',
      'savedAt': DateTime.now().toIso8601String(),
      'playCount': 0,
    });

    // Keep only last 20 quizzes
    if (savedQuizzes.length > 20) {
      savedQuizzes.removeAt(0);
    }

    await _quizBox!.put(_savedQuizzesKey, savedQuizzes);
    debugPrint('📴 Quiz saved for offline: $title');
  }

  /// Get all saved offline quizzes
  List<Map<String, dynamic>> getSavedQuizzes() {
    return _getSavedQuizzes();
  }

  List<Map<String, dynamic>> _getSavedQuizzes() {
    if (_quizBox == null) return [];
    final raw = _quizBox!.get(_savedQuizzesKey, defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// Delete saved quiz
  Future<void> deleteSavedQuiz(String quizId) async {
    if (_quizBox == null) await initialize();
    final savedQuizzes = _getSavedQuizzes();
    savedQuizzes.removeWhere((q) => q['id'] == quizId);
    await _quizBox!.put(_savedQuizzesKey, savedQuizzes);
  }

  /// Get a saved quiz by ID
  Map<String, dynamic>? getSavedQuiz(String quizId) {
    final quizzes = _getSavedQuizzes();
    try {
      return quizzes.firstWhere((q) => q['id'] == quizId);
    } catch (e) {
      return null;
    }
  }

  /// Increment play count for a quiz
  Future<void> incrementPlayCount(String quizId) async {
    if (_quizBox == null) await initialize();
    final savedQuizzes = _getSavedQuizzes();
    final index = savedQuizzes.indexWhere((q) => q['id'] == quizId);
    if (index != -1) {
      savedQuizzes[index]['playCount'] =
          (savedQuizzes[index]['playCount'] ?? 0) + 1;
      await _quizBox!.put(_savedQuizzesKey, savedQuizzes);
    }
  }

  // ==========================================
  // DAILY CHALLENGE (OFFLINE)
  // ==========================================

  /// Get today's daily challenge
  /// Returns null if no quiz data available
  Map<String, dynamic>? getTodaysChallenge() {
    if (_dailyChallengeBox == null) return null;

    final today = _formatDate(DateTime.now());
    final savedDate = _dailyChallengeBox!.get(_challengeDateKey);

    // If already generated for today, return it
    if (savedDate == today) {
      final challenge = _dailyChallengeBox!.get(_todaysChallengeKey);
      if (challenge != null) {
        return Map<String, dynamic>.from(challenge as Map);
      }
    }

    // Generate new daily challenge
    return _generateDailyChallenge();
  }

  Map<String, dynamic>? _generateDailyChallenge() {
    // Get practice questions pool
    final practicePool = _getPracticeQuestions();
    if (practicePool.isEmpty) return null;

    // Shuffle and take 10 questions
    practicePool.shuffle(_random);
    final challengeQuestions = practicePool.take(10).toList();

    final challenge = {
      'id': 'daily_${_formatDate(DateTime.now())}',
      'title': 'Daily Challenge',
      'questions': challengeQuestions,
      'difficulty': 'mixed',
      'date': _formatDate(DateTime.now()),
      'timeLimit': 15, // seconds per question
    };

    // Save
    _dailyChallengeBox!.put(_todaysChallengeKey, challenge);
    _dailyChallengeBox!.put(_challengeDateKey, _formatDate(DateTime.now()));
    _dailyChallengeBox!.put(_challengeCompletedKey, false);

    debugPrint(
      '🎯 Generated daily challenge with ${challengeQuestions.length} questions',
    );
    return challenge;
  }

  /// Check if today's challenge is completed
  bool isTodaysChallengeCompleted() {
    if (_dailyChallengeBox == null) return false;
    return _dailyChallengeBox!.get(_challengeCompletedKey, defaultValue: false);
  }

  /// Mark today's challenge as completed
  Future<void> markChallengeCompleted() async {
    if (_dailyChallengeBox == null) await initialize();
    await _dailyChallengeBox!.put(_challengeCompletedKey, true);
    debugPrint('✅ Daily challenge completed!');
  }

  // ==========================================
  // PRACTICE MODE (OFFLINE)
  // ==========================================

  /// Add questions to practice pool (called when quiz is completed)
  Future<void> addToPracticePool(List<Map<String, dynamic>> questions) async {
    if (_quizBox == null) await initialize();

    final practicePool = _getPracticeQuestions();

    for (final q in questions) {
      // Avoid duplicates based on question text
      final exists = practicePool.any(
        (p) => p['questionText'] == q['questionText'],
      );
      if (!exists) {
        practicePool.add(q);
      }
    }

    // Keep pool size manageable (max 200 questions)
    if (practicePool.length > 200) {
      practicePool.removeRange(0, practicePool.length - 200);
    }

    await _quizBox!.put(_practiceQuestionsKey, practicePool);
    debugPrint('📚 Practice pool now has ${practicePool.length} questions');
  }

  List<Map<String, dynamic>> _getPracticeQuestions() {
    if (_quizBox == null) return [];
    final raw = _quizBox!.get(_practiceQuestionsKey, defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// Get random practice questions
  List<Map<String, dynamic>> getPracticeQuestions({int count = 10}) {
    final pool = _getPracticeQuestions();
    if (pool.isEmpty) return [];

    pool.shuffle(_random);
    return pool.take(count).toList();
  }

  /// Get practice pool size
  int getPracticePoolSize() {
    return _getPracticeQuestions().length;
  }

  // ==========================================
  // QUICK QUIZ (OFFLINE)
  // ==========================================

  /// Generate a quick quiz from saved content
  Map<String, dynamic>? generateQuickQuiz({int questionCount = 5}) {
    final pool = _getPracticeQuestions();
    if (pool.length < questionCount) return null;

    pool.shuffle(_random);
    final questions = pool.take(questionCount).toList();

    return {
      'id': 'quick_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Quick Quiz',
      'questions': questions,
      'difficulty': 'mixed',
      'isQuickQuiz': true,
    };
  }

  // ==========================================
  // STATS
  // ==========================================

  /// Get offline content stats
  Map<String, int> getOfflineStats() {
    return {
      'savedQuizzes': _getSavedQuizzes().length,
      'practiceQuestions': _getPracticeQuestions().length,
      'hasDailyChallenge': getTodaysChallenge() != null ? 1 : 0,
    };
  }

  // ==========================================
  // PERSONALIZED PRACTICE (Based on Last Quiz)
  // ==========================================

  static const String _lastQuizKey = 'last_quiz_info';
  static const String _personalizedPracticeKey = 'personalized_practice';
  static const String _personalizedPracticeDateKey =
      'personalized_practice_date';
  static const String _personalizedPracticeUsedKey =
      'personalized_practice_used';

  /// Save last quiz info for personalized practice
  Future<void> saveLastQuizInfo({
    required String quizId,
    required String title,
    required String topic,
    required List<Map<String, dynamic>> questions,
    required int score,
    required int totalQuestions,
    String? difficulty,
  }) async {
    if (_quizBox == null) await initialize();

    final lastQuizInfo = {
      'quizId': quizId,
      'title': title,
      'topic': topic,
      'questions': questions,
      'score': score,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty ?? 'medium',
      'completedAt': DateTime.now().toIso8601String(),
      'wrongCount': totalQuestions - score,
    };

    await _quizBox!.put(_lastQuizKey, lastQuizInfo);
    debugPrint('📝 Saved last quiz info: $title');

    // Generate personalized practice if not already generated today
    await _generatePersonalizedPractice(lastQuizInfo);
  }

  /// Get last quiz info
  Map<String, dynamic>? getLastQuizInfo() {
    if (_quizBox == null) return null;
    final raw = _quizBox!.get(_lastQuizKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  /// Generate personalized practice based on last quiz
  Future<void> _generatePersonalizedPractice(
    Map<String, dynamic> lastQuiz,
  ) async {
    final today = _formatDate(DateTime.now());
    final existingDate = _quizBox!.get(_personalizedPracticeDateKey);

    // Only generate once per day
    if (existingDate == today) {
      debugPrint('📚 Personalized practice already generated today');
      return;
    }

    final questions = (lastQuiz['questions'] as List<dynamic>?) ?? [];
    if (questions.isEmpty) return;

    // Shuffle and create practice quiz
    final practiceQuestions = List<Map<String, dynamic>>.from(
      questions.map((e) => Map<String, dynamic>.from(e as Map)),
    );
    practiceQuestions.shuffle(_random);

    // Take up to 10 questions for practice
    final selectedQuestions = practiceQuestions.take(10).toList();

    final topic = lastQuiz['topic'] ?? lastQuiz['title'] ?? 'Your Last Topic';

    final personalizedPractice = {
      'id': 'personalized_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Practice: $topic',
      'topic': topic,
      'questions': selectedQuestions,
      'difficulty': lastQuiz['difficulty'] ?? 'medium',
      'basedOnQuizId': lastQuiz['quizId'],
      'isAdFree': true, // No ads for daily personalized practice
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String(),
    };

    await _quizBox!.put(_personalizedPracticeKey, personalizedPractice);
    await _quizBox!.put(_personalizedPracticeDateKey, today);
    await _quizBox!.put(_personalizedPracticeUsedKey, false);

    debugPrint(
      '🎯 Generated personalized practice: $topic with ${selectedQuestions.length} questions',
    );
  }

  /// Get today's personalized practice quiz (ad-free, once daily)
  /// Returns null if already used today or no last quiz data
  Map<String, dynamic>? getPersonalizedPractice() {
    if (_quizBox == null) return null;

    final today = _formatDate(DateTime.now());
    final practiceDate = _quizBox!.get(_personalizedPracticeDateKey);

    // Check if practice is from today
    if (practiceDate != today) {
      // Try to generate from last quiz
      final lastQuiz = getLastQuizInfo();
      if (lastQuiz != null) {
        _generatePersonalizedPractice(lastQuiz);
      } else {
        return null;
      }
    }

    // Check if already used today
    final alreadyUsed = _quizBox!.get(
      _personalizedPracticeUsedKey,
      defaultValue: false,
    );
    if (alreadyUsed == true) {
      return null; // Already used today's practice
    }

    final practice = _quizBox!.get(_personalizedPracticeKey);
    if (practice == null) return null;

    return Map<String, dynamic>.from(practice as Map);
  }

  /// Mark personalized practice as used (consumed for today)
  Future<void> markPersonalizedPracticeUsed() async {
    if (_quizBox == null) await initialize();
    await _quizBox!.put(_personalizedPracticeUsedKey, true);
    debugPrint('✅ Personalized practice used for today');
  }

  /// Check if personalized practice is available (not yet used today)
  bool isPersonalizedPracticeAvailable() {
    if (_quizBox == null) return false;

    final today = _formatDate(DateTime.now());
    final practiceDate = _quizBox!.get(_personalizedPracticeDateKey);

    // No practice generated for today
    if (practiceDate != today) {
      // Check if we have last quiz to generate from
      return getLastQuizInfo() != null;
    }

    // Check if already used
    return _quizBox!.get(_personalizedPracticeUsedKey, defaultValue: false) !=
        true;
  }

  /// Get personalized practice info for notifications
  PersonalizedPracticeInfo? getPersonalizedPracticeInfo() {
    final lastQuiz = getLastQuizInfo();
    if (lastQuiz == null) return null;

    final topic = lastQuiz['topic'] ?? lastQuiz['title'] ?? 'Recent Topic';
    final wrongCount = lastQuiz['wrongCount'] ?? 0;
    final isAvailable = isPersonalizedPracticeAvailable();

    return PersonalizedPracticeInfo(
      topic: topic,
      wrongCount: wrongCount,
      isAvailable: isAvailable,
      lastQuizDate: lastQuiz['completedAt'] != null
          ? DateTime.tryParse(lastQuiz['completedAt'] as String)
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Info about personalized practice for notifications
class PersonalizedPracticeInfo {
  final String topic;
  final int wrongCount;
  final bool isAvailable;
  final DateTime? lastQuizDate;

  PersonalizedPracticeInfo({
    required this.topic,
    required this.wrongCount,
    required this.isAvailable,
    this.lastQuizDate,
  });

  /// Get days since last quiz
  int get daysSinceLastQuiz {
    if (lastQuizDate == null) return 0;
    return DateTime.now().difference(lastQuizDate!).inDays;
  }

  /// Get smart notification message
  String getNotificationMessage() {
    if (daysSinceLastQuiz >= 3) {
      return "You're forgetting $topic. Practice now to retain it!";
    } else if (wrongCount > 0) {
      return "You missed $wrongCount questions on $topic. Ready to master it?";
    } else {
      return "Great job on $topic! Want to strengthen your knowledge?";
    }
  }
}
