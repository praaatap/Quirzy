// ============================================================================
// QUIRZY - PROPRIETARY AND CONFIDENTIAL
// ============================================================================
// Copyright (c) 2025 Quirzy. All Rights Reserved.
//
// This source code is licensed under the Quirzy Proprietary License.
// See the LICENSE file in the root directory for full terms.
//
// UNAUTHORIZED COPYING, MODIFICATION, DISTRIBUTION, OR USE IS STRICTLY
// PROHIBITED. This code is provided for VIEWING PURPOSES ONLY.
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:quirzy/data/models/quiz_model.dart';
import 'package:quirzy/data/models/quiz_result_model.dart';
import 'package:quirzy/domain/usecases/quiz_usecases.dart';

/// Quiz generation state
class QuizGenerationState {
  final bool isLoading;
  final QuizModel? quiz;
  final String? error;

  const QuizGenerationState({this.isLoading = false, this.quiz, this.error});

  QuizGenerationState copyWith({
    bool? isLoading,
    QuizModel? quiz,
    String? error,
  }) {
    return QuizGenerationState(
      isLoading: isLoading ?? this.isLoading,
      quiz: quiz ?? this.quiz,
      error: error,
    );
  }

  factory QuizGenerationState.initial() => const QuizGenerationState();
}

/// Quiz generation notifier
class QuizGenerationNotifier extends StateNotifier<QuizGenerationState> {
  final QuizUseCases _useCases;

  QuizGenerationNotifier({QuizUseCases? useCases})
    : _useCases = useCases ?? QuizUseCases(),
      super(QuizGenerationState.initial());

  /// Generate quiz from topic
  Future<QuizModel?> generateQuiz({
    required String topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final quiz = await _useCases.generateQuiz(
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      state = state.copyWith(isLoading: false, quiz: quiz);
      debugPrint('✅ Quiz generated: ${quiz.id}');
      return quiz;
    } catch (e) {
      debugPrint('❌ Generate quiz error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Generate quiz from file
  Future<QuizModel?> generateQuizFromFile({
    required File file,
    required String fileType,
    String? topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final quiz = await _useCases.generateQuizFromFile(
        file: file,
        fileType: fileType,
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      state = state.copyWith(isLoading: false, quiz: quiz);
      debugPrint('✅ Quiz generated from file: ${quiz.id}');
      return quiz;
    } catch (e) {
      debugPrint('❌ Generate quiz from file error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Clear current quiz
  void clearQuiz() {
    state = QuizGenerationState.initial();
  }
}

/// Quiz history state
class QuizHistoryState {
  final bool isLoading;
  final List<QuizResultModel> history;
  final Map<String, dynamic>? stats;
  final String? error;

  const QuizHistoryState({
    this.isLoading = false,
    this.history = const [],
    this.stats,
    this.error,
  });

  QuizHistoryState copyWith({
    bool? isLoading,
    List<QuizResultModel>? history,
    Map<String, dynamic>? stats,
    String? error,
  }) {
    return QuizHistoryState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      stats: stats ?? this.stats,
      error: error,
    );
  }

  factory QuizHistoryState.initial() => const QuizHistoryState();
}

/// Quiz history notifier
class QuizHistoryNotifier extends StateNotifier<QuizHistoryState> {
  final QuizUseCases _useCases;

  QuizHistoryNotifier({QuizUseCases? useCases})
    : _useCases = useCases ?? QuizUseCases(),
      super(QuizHistoryState.initial());

  /// Fetch quiz history
  Future<void> fetchHistory() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final history = await _useCases.getQuizHistory();
      final stats = await _useCases.calculateQuizStats();

      state = state.copyWith(isLoading: false, history: history, stats: stats);

      debugPrint('✅ Fetched ${history.length} history records');
    } catch (e) {
      debugPrint('❌ Fetch history error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Submit quiz result
  Future<void> submitResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    int? timeTaken,
  }) async {
    try {
      await _useCases.submitQuizResult(
        quizId: quizId,
        quizTitle: quizTitle,
        score: score,
        totalQuestions: totalQuestions,
        questions: questions,
        userSelectedAnswers: userSelectedAnswers,
        timeTaken: timeTaken,
      );

      debugPrint('✅ Quiz result submitted');

      // Refresh history after submission
      await fetchHistory();
    } catch (e) {
      debugPrint('❌ Submit result error: $e');
      rethrow;
    }
  }

  /// Clear history
  void clearHistory() {
    state = QuizHistoryState.initial();
  }
}

/// My quizzes state
class MyQuizzesState {
  final bool isLoading;
  final List<QuizModel> quizzes;
  final String? error;

  const MyQuizzesState({
    this.isLoading = false,
    this.quizzes = const [],
    this.error,
  });

  MyQuizzesState copyWith({
    bool? isLoading,
    List<QuizModel>? quizzes,
    String? error,
  }) {
    return MyQuizzesState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      error: error,
    );
  }

  factory MyQuizzesState.initial() => const MyQuizzesState();
}

/// My quizzes notifier
class MyQuizzesNotifier extends StateNotifier<MyQuizzesState> {
  final QuizUseCases _useCases;

  MyQuizzesNotifier({QuizUseCases? useCases})
    : _useCases = useCases ?? QuizUseCases(),
      super(MyQuizzesState.initial());

  /// Fetch my quizzes
  Future<void> fetchMyQuizzes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final quizzes = await _useCases.getMyQuizzes();

      state = state.copyWith(isLoading: false, quizzes: quizzes);
      debugPrint('✅ Fetched ${quizzes.length} quizzes');
    } catch (e) {
      debugPrint('❌ Fetch my quizzes error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _useCases.deleteQuiz(quizId);

      // Remove from local state
      final updatedQuizzes = state.quizzes
          .where((quiz) => quiz.id != quizId)
          .toList();

      state = state.copyWith(quizzes: updatedQuizzes);
      debugPrint('✅ Quiz deleted: $quizId');
    } catch (e) {
      debugPrint('❌ Delete quiz error: $e');
      rethrow;
    }
  }
}

// Providers
final quizGenerationProvider =
    StateNotifierProvider<QuizGenerationNotifier, QuizGenerationState>((ref) {
      return QuizGenerationNotifier();
    });

final quizHistoryProvider =
    StateNotifierProvider<QuizHistoryNotifier, QuizHistoryState>((ref) {
      return QuizHistoryNotifier();
    });

final myQuizzesProvider =
    StateNotifierProvider<MyQuizzesNotifier, MyQuizzesState>((ref) {
      return MyQuizzesNotifier();
    });
