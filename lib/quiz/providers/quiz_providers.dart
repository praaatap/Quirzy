import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quiz_service.dart';

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
