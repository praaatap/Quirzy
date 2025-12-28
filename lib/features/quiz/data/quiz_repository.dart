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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/models/quiz_model.dart';
import 'package:quirzy/models/quiz_result_model.dart';
import 'package:quirzy/core/constants/constant.dart';
import 'package:quirzy/core/services/storage/token_storage.dart';

/// Repository for quiz operations
/// Handles quiz generation, fetching, and result management
/// Merged with UseCase and DataSource logic for simplicity
class QuizRepository {
  final http.Client _client;

  QuizRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Get authentication token or throw
  Future<String> _getToken() async {
    final token = await TokenStorage.getToken();
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

    try {
      final token = await _getToken();
      debugPrint('🎯 Generating quiz for topic: $topic');

      final response = await _client
          .post(
            Uri.parse('$kBackendApiUrl/quiz/generate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'topic': topic.trim(),
              'questionCount': questionCount,
              'difficulty': difficulty.toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('Quiz generation response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Quiz generated successfully');
        return QuizModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to generate quiz');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on http.ClientException {
      throw Exception('Connection error. Please try again.');
    } catch (e) {
      debugPrint('❌ Quiz generation error: $e');
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
    // Validation
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final validFileTypes = ['pdf', 'txt', 'docx', 'image'];
    if (!validFileTypes.contains(fileType.toLowerCase())) {
      throw Exception('Invalid file type. Supported: PDF, TXT, DOCX, Image');
    }

    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw Exception('File size too large. Maximum 10MB allowed');
    }

    if (questionCount < 1 || questionCount > 50) {
      throw Exception('Question count must be between 1 and 50');
    }

    try {
      final token = await _getToken();
      debugPrint('📄 Generating quiz from $fileType file');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBackendApiUrl/quiz/generate-from-file'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['fileType'] = fileType.toLowerCase();
      request.fields['questionCount'] = questionCount.toString();
      request.fields['difficulty'] = difficulty.toLowerCase();

      if (topic != null && topic.trim().isNotEmpty) {
        request.fields['topic'] = topic.trim();
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint(
        '📤 Uploading file (${(fileSize / 1024).toStringAsFixed(2)} KB)...',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Quiz from file response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return QuizModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['error'] ?? 'Failed to generate quiz from file',
        );
      }
    } catch (e) {
      debugPrint('❌ Quiz from file error: $e');
      rethrow;
    }
  }

  /// Get a specific quiz by ID
  Future<QuizModel> getQuiz(String quizId) async {
    if (quizId.isEmpty) throw Exception('Quiz ID is required');

    try {
      final token = await _getToken();
      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/quiz/$quizId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return QuizModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch quiz');
      }
    } catch (e) {
      debugPrint('❌ Get quiz repository error: $e');
      rethrow;
    }
  }

  /// Get all quizzes created by user
  Future<List<QuizModel>> getMyQuizzes() async {
    try {
      final token = await _getToken();
      debugPrint('📋 Fetching created quizzes...');

      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/quiz/my-quizzes'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Get my quizzes response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is Map && data.containsKey('quizzes')) {
          list = data['quizzes'];
        } else if (data is List) {
          list = data;
        }
        return list.map((json) => QuizModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Get my quizzes repository error: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    if (quizId.isEmpty) throw Exception('Quiz ID is required');
    try {
      final token = await _getToken();
      final response = await _client
          .delete(
            Uri.parse('$kBackendApiUrl/quiz/$quizId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete quiz');
      }
    } catch (e) {
      debugPrint('❌ Delete quiz repository error: $e');
      rethrow;
    }
  }

  /// Submit quiz result
  Future<void> saveQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    int? timeTaken,
  }) async {
    // Validation
    if (quizId.isEmpty) throw Exception('Quiz ID is required');
    if (totalQuestions <= 0) throw Exception('Invalid quiz data');
    if (score < 0 || score > totalQuestions) throw Exception('Invalid score');
    if (userSelectedAnswers.length != totalQuestions) {
      throw Exception('Please answer all questions');
    }

    try {
      final token = await _getToken();
      debugPrint('📝 Saving quiz result for ID: $quizId');

      final bodyData = {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'questions': questions,
        'userSelectedAnswers': userSelectedAnswers,
        'timeTaken': timeTaken ?? 0,
      };

      final response = await _client
          .post(
            Uri.parse('$kBackendApiUrl/quiz/result'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(bodyData),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Result saved successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save result');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Save quiz result repository error: $e');
      rethrow;
    }
  }

  /// Get quiz history
  Future<List<QuizResultModel>> getQuizHistory() async {
    try {
      final token = await _getToken();
      debugPrint('📜 Fetching quiz history...');

      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/quiz/results'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => QuizResultModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch history');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Get quiz history repository error: $e');
      rethrow;
    }
  }

  /// Calculate quiz statistics from history
  Future<Map<String, dynamic>> calculateQuizStats() async {
    final history = await getQuizHistory();

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
