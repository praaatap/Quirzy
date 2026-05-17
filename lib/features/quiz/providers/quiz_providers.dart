import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/services.dart';
import '../services/mock_test_service.dart';
import '../services/study_material_service.dart';

/// Provider for QuizService singleton
final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

/// Provider for quiz history - auto-refreshes when invalidated
final quizHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final quizService = ref.watch(quizServiceProvider);
  return quizService.getQuizHistory();
});

/// Provider for user's quizzes list
final myQuizzesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final quizService = ref.watch(quizServiceProvider);
  return quizService.getMyQuizzes();
});

/// Provider for daily quiz service
final dailyQuizServiceProvider = Provider<DailyQuizService>((ref) {
  return DailyQuizService();
});

/// Provider to check if user can generate a quiz (daily limit check)
final canGenerateQuizProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final lastDate = prefs.getString('last_quiz_generation_date');
  final today = DateTime.now().toIso8601String().split('T').first;
  
  // Reset if it's a new day
  if (lastDate != today) {
    return true;
  }
  
  final quizCount = prefs.getInt('daily_quiz_generation_count') ?? 0;
  return quizCount < 2; // Free users get 2 quizzes per day
});

/// Providers for new services
final challengeServiceProvider = Provider<ChallengeService>((ref) => ChallengeService());
final studyQuizServiceProvider = Provider<StudyQuizService>((ref) => StudyQuizService());
final mockTestServiceProvider = Provider<MockTestService>((ref) => MockTestService());
final studyMaterialServiceProvider = Provider<StudyMaterialService>((ref) => StudyMaterialService());

final mockTestHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(mockTestServiceProvider).getMockTestHistory();
});

final studyMaterialHistoryProvider = FutureProvider<List<StudyMaterial>>((ref) async {
  return ref.read(studyMaterialServiceProvider).getStudyHistory();
});

final myChallengesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(challengeServiceProvider);
  return service.getMyChallenges();
});

/// Daily Quiz Service - manages daily quiz limits and generation
class DailyQuizService {
  Future<void> recordDailyQuizUsage({
    required String quizId,
    required String topic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    
    final lastDate = prefs.getString('last_quiz_generation_date');
    if (lastDate != today) {
      // New day, reset counter
      await prefs.setString('last_quiz_generation_date', today);
      await prefs.setInt('daily_quiz_generation_count', 1);
    } else {
      // Same day, increment counter
      final count = (prefs.getInt('daily_quiz_generation_count') ?? 0) + 1;
      await prefs.setInt('daily_quiz_generation_count', count);
    }
  }
  
  Future<int> getDailyQuizCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_quiz_generation_date');
    final today = DateTime.now().toIso8601String().split('T').first;
    
    if (lastDate != today) {
      return 0;
    }
    
    return prefs.getInt('daily_quiz_generation_count') ?? 0;
  }
  
  Future<bool> hasReachedDailyLimit() async {
    final count = await getDailyQuizCount();
    return count >= 2; // Free limit: 2 quizzes per day
  }

  Future<void> addXPToday(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final key = 'xp_today_$today';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + xp);
  }

  Future<int> getXPToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    return prefs.getInt('xp_today_$today') ?? 0;
  }
}
