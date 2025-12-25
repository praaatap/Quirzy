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
import 'package:quirzy/data/datasources/local/auth_local_datasource.dart';
import 'package:quirzy/data/datasources/remote/quiz_remote_datasource.dart';
import 'package:quirzy/data/models/quiz_model.dart';
import 'package:quirzy/data/models/quiz_result_model.dart';

/// Repository for quiz operations
/// Handles quiz generation, fetching, and result management
class QuizRepository {
  final QuizRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  QuizRepository({
    QuizRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? authLocalDataSource,
  }) : _remoteDataSource = remoteDataSource ?? QuizRemoteDataSource(),
       _authLocalDataSource = authLocalDataSource ?? AuthLocalDataSource();

  /// Get authentication token or throw
  Future<String> _getToken() async {
    final token = await _authLocalDataSource.getToken();
    if (token == null) {
      throw Exception('Please login to continue');
    }
    return token;
  }

  /// Generate quiz from topic using AI
  Future<QuizModel> generateQuiz({
    required String topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      final token = await _getToken();

      final response = await _remoteDataSource.generateQuiz(
        token: token,
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      return QuizModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Generate quiz repository error: $e');
      rethrow;
    }
  }

  /// Generate quiz from file
  Future<QuizModel> generateQuizFromFile({
    required File file,
    required String fileType,
    String? topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      final token = await _getToken();

      final response = await _remoteDataSource.generateQuizFromFile(
        token: token,
        file: file,
        fileType: fileType,
        topic: topic,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      return QuizModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Generate quiz from file repository error: $e');
      rethrow;
    }
  }

  /// Get a specific quiz by ID
  Future<QuizModel> getQuiz(String quizId) async {
    try {
      final token = await _getToken();

      final response = await _remoteDataSource.getQuiz(
        token: token,
        quizId: quizId,
      );

      return QuizModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Get quiz repository error: $e');
      rethrow;
    }
  }

  /// Get all quizzes created by user
  Future<List<QuizModel>> getMyQuizzes() async {
    try {
      final token = await _getToken();

      final response = await _remoteDataSource.getMyQuizzes(token: token);

      return response.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get my quizzes repository error: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      final token = await _getToken();

      await _remoteDataSource.deleteQuiz(token: token, quizId: quizId);
    } catch (e) {
      debugPrint('❌ Delete quiz repository error: $e');
      rethrow;
    }
  }

  /// Save quiz result after completing a quiz
  Future<void> saveQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    int? timeTaken,
  }) async {
    try {
      final token = await _getToken();

      await _remoteDataSource.saveQuizResult(
        token: token,
        quizId: quizId,
        quizTitle: quizTitle,
        score: score,
        totalQuestions: totalQuestions,
        questions: questions,
        userSelectedAnswers: userSelectedAnswers,
        timeTaken: timeTaken,
      );
    } catch (e) {
      debugPrint('❌ Save quiz result repository error: $e');
      rethrow;
    }
  }

  /// Get quiz history (all attempts)
  Future<List<QuizResultModel>> getQuizHistory() async {
    try {
      final token = await _getToken();

      final response = await _remoteDataSource.getQuizHistory(token: token);

      return response.map((json) => QuizResultModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get quiz history repository error: $e');
      rethrow;
    }
  }
}
