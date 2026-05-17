import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature 1: Quick Practice Mode
/// Instant 5-question practice from cached quiz history
class QuickPracticeService {
  static QuickPracticeService? _instance;
  static const String _lastPracticeKey = 'last_quick_practice';

  factory QuickPracticeService() {
    _instance ??= QuickPracticeService._internal();
    return _instance!;
  }

  QuickPracticeService._internal();

  /// Generate quick practice quiz from cached questions
  Future<List<Map<String, dynamic>>> generateQuickPractice({
    required List<Map<String, dynamic>> quizHistory,
    String? topic,
  }) async {
    if (quizHistory.isEmpty) {
      return [];
    }

    final random = Random();
    final questions = <Map<String, dynamic>>[];

    // Filter by topic if specified
    final filteredHistory = topic != null
        ? quizHistory.where((q) => q['topic'] == topic).toList()
        : quizHistory;

    if (filteredHistory.isEmpty) return [];

    // Pick 5 random questions from history
    final shuffled = List.from(filteredHistory)..shuffle(random);
    final selected = shuffled.take(5).toList();

    for (final quiz in selected) {
      final quizQuestions = quiz['questions'] as List?;
      if (quizQuestions != null && quizQuestions.isNotEmpty) {
        final randomQuestion = quizQuestions[random.nextInt(quizQuestions.length)];
        questions.add(randomQuestion);
      }
    }

    // Mark practice time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPracticeKey, DateTime.now().toIso8601String());

    return questions;
  }

  /// Check if user can do quick practice (cooldown: 5 minutes)
  Future<bool> canPractice() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPractice = prefs.getString(_lastPracticeKey);
    
    if (lastPractice == null) return true;

    final lastTime = DateTime.parse(lastPractice);
    final now = DateTime.now();
    final difference = now.difference(lastTime);

    return difference.inMinutes >= 5;
  }

  /// Get remaining cooldown time
  Future<Duration> getCooldownTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPractice = prefs.getString(_lastPracticeKey);
    
    if (lastPractice == null) return Duration.zero;

    final lastTime = DateTime.parse(lastPractice);
    final now = DateTime.now();
    final elapsed = now.difference(lastTime);
    final remaining = Duration(minutes: 5) - elapsed;

    return remaining > Duration.zero ? remaining : Duration.zero;
  }
}
