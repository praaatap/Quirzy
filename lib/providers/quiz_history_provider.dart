// lib/providers/quiz_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/utils/appwrite.dart';

class QuizHistoryState {
  final List<models.Document>? quizzes;
  final bool isLoading;
  final String? error;

  QuizHistoryState({
    this.quizzes,
    this.isLoading = false,
    this.error,
  });
}

class QuizHistoryNotifier extends StateNotifier<QuizHistoryState> {
  final Ref ref;
  late final Databases _databases;

  QuizHistoryNotifier(this.ref) : super(QuizHistoryState()) {
    final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(APPWRITE_PROJECT_ID);
    _databases = Databases(client);
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    try {
      state = QuizHistoryState(isLoading: true, error: null);
      
      final response = await _databases.listDocuments(
        databaseId: '6857d4c7000bdb83227a',
        collectionId: 'quiz_history',
        queries: [
          Query.equal('userId', ref.read(authProvider).user?.$id ?? ''),
          Query.orderDesc('date'),
        ],
      );
      
      state = QuizHistoryState(
        quizzes: response.documents,
        isLoading: false,
      );
    } catch (e) {
      state = QuizHistoryState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> saveQuizResult({
    required String quizTitle,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: '6857d4c7000bdb83227a',
        collectionId: 'quiz_history',
        documentId: ID.unique(),
        data: {
          'userId': ref.read(authProvider).user?.$id ?? '',
          'quizTitle': quizTitle,
          'score': score,
          'totalQuestions': totalQuestions,
          'date': DateTime.now().toIso8601String(),
        },
      );
      await _loadQuizHistory();
    } catch (e) {
      state = QuizHistoryState(
        error: e.toString(),
        quizzes: state.quizzes,
      );
    }
  }
}

final quizHistoryProvider = StateNotifierProvider<QuizHistoryNotifier, QuizHistoryState>((ref) {
  return QuizHistoryNotifier(ref);
});