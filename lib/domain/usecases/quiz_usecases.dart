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
import 'package:quirzy/data/models/quiz_model.dart';
import 'package:quirzy/data/models/quiz_result_model.dart';
import 'package:quirzy/data/repositories/quiz_repository.dart';

/// Use cases for quiz operations
/// Contains the business logic for quiz-related actions
class QuizUseCases {
  final QuizRepository _repository;

  QuizUseCases({QuizRepository? repository})
    : _repository = repository ?? QuizRepository();

  /// Generate a quiz from a topic
  Future<QuizModel> generateQuiz({
    required String topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    // Validation
    if (topic.trim().isEmpty) {
      throw Exception('Please enter a topic');
    }

    if (questionCount < 1 || questionCount > 50) {
      throw Exception('Question count must be between 1 and 50');
    }

    if (!['easy', 'medium', 'hard'].contains(difficulty.toLowerCase())) {
      throw Exception('Invalid difficulty level');
    }

    return await _repository.generateQuiz(
      topic: topic.trim(),
      questionCount: questionCount,
      difficulty: difficulty.toLowerCase(),
    );
  }

  /// Generate a quiz from a file
  Future<QuizModel> generateQuizFromFile({
    required File file,
    required String fileType,
    String? topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    // Validation
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final validFileTypes = ['pdf', 'txt', 'docx', 'image'];
    if (!validFileTypes.contains(fileType.toLowerCase())) {
      throw Exception('Invalid file type. Supported: PDF, TXT, DOCX, Image');
    }

    // Check file size (max 10MB)
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw Exception('File size too large. Maximum 10MB allowed');
    }

    if (questionCount < 1 || questionCount > 50) {
      throw Exception('Question count must be between 1 and 50');
    }

    return await _repository.generateQuizFromFile(
      file: file,
      fileType: fileType.toLowerCase(),
      topic: topic?.trim(),
      questionCount: questionCount,
      difficulty: difficulty.toLowerCase(),
    );
  }

  /// Get a specific quiz by ID
  Future<QuizModel> getQuiz(String quizId) async {
    if (quizId.isEmpty) {
      throw Exception('Quiz ID is required');
    }

    return await _repository.getQuiz(quizId);
  }

  /// Get all quizzes created by user
  Future<List<QuizModel>> getMyQuizzes() async {
    return await _repository.getMyQuizzes();
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    if (quizId.isEmpty) {
      throw Exception('Quiz ID is required');
    }

    await _repository.deleteQuiz(quizId);
  }

  /// Submit quiz result
  Future<void> submitQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    int? timeTaken,
  }) async {
    // Validation
    if (quizId.isEmpty) {
      throw Exception('Quiz ID is required');
    }

    if (totalQuestions <= 0) {
      throw Exception('Invalid quiz data');
    }

    if (score < 0 || score > totalQuestions) {
      throw Exception('Invalid score');
    }

    if (userSelectedAnswers.length != totalQuestions) {
      throw Exception('Please answer all questions');
    }

    await _repository.saveQuizResult(
      quizId: quizId,
      quizTitle: quizTitle,
      score: score,
      totalQuestions: totalQuestions,
      questions: questions,
      userSelectedAnswers: userSelectedAnswers,
      timeTaken: timeTaken,
    );
  }

  /// Get quiz history
  Future<List<QuizResultModel>> getQuizHistory() async {
    return await _repository.getQuizHistory();
  }

  /// Calculate quiz statistics from history
  Future<Map<String, dynamic>> calculateQuizStats() async {
    final history = await _repository.getQuizHistory();

    if (history.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'totalQuestions': 0,
        'correctAnswers': 0,
        'totalTimeTaken': 0,
      };
    }

    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalTimeTaken = 0;
    double bestPercentage = 0;

    for (final result in history) {
      totalQuestions += result.totalQuestions;
      totalCorrect += result.score;
      totalTimeTaken += result.timeTaken;

      if (result.percentage > bestPercentage) {
        bestPercentage = result.percentage;
      }
    }

    return {
      'totalQuizzes': history.length,
      'averageScore': totalQuestions > 0
          ? (totalCorrect / totalQuestions) * 100
          : 0.0,
      'bestScore': bestPercentage,
      'totalQuestions': totalQuestions,
      'correctAnswers': totalCorrect,
      'totalTimeTaken': totalTimeTaken,
    };
  }
}
