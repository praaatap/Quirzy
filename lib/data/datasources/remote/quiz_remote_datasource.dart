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
import 'package:quirzy/utils/constant.dart';

/// Remote data source for quiz-related API calls
/// Handles all HTTP communication with quiz endpoints
class QuizRemoteDataSource {
  final http.Client _client;

  QuizRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Generate quiz from topic using AI
  Future<Map<String, dynamic>> generateQuiz({
    required String token,
    required String topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      debugPrint('🎯 Generating quiz for topic: $topic');

      final response = await _client
          .post(
            Uri.parse('$kBackendApiUrl/quiz/generate'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'topic': topic,
              'questionCount': questionCount,
              'difficulty': difficulty,
            }),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('Quiz generation response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Quiz generated successfully');
        return jsonDecode(response.body) as Map<String, dynamic>;
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
  Future<Map<String, dynamic>> generateQuizFromFile({
    required String token,
    required File file,
    required String fileType,
    String? topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      debugPrint('📄 Generating quiz from $fileType file');

      // Check file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File size too large. Maximum 10MB allowed.');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBackendApiUrl/quiz/generate-from-file'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['fileType'] = fileType;
      request.fields['questionCount'] = questionCount.toString();
      request.fields['difficulty'] = difficulty;

      if (topic != null && topic.isNotEmpty) {
        request.fields['topic'] = topic;
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
        return jsonDecode(response.body) as Map<String, dynamic>;
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
  Future<Map<String, dynamic>> getQuiz({
    required String token,
    required String quizId,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/quiz/$quizId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch quiz');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all quizzes created by user
  Future<List<Map<String, dynamic>>> getMyQuizzes({
    required String token,
  }) async {
    try {
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
        if (data is Map && data.containsKey('quizzes')) {
          final quizzes = List<Map<String, dynamic>>.from(data['quizzes']);
          debugPrint('✅ Fetched ${quizzes.length} created quizzes');
          return quizzes;
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Fetch quizzes error: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz({
    required String token,
    required String quizId,
  }) async {
    try {
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
      rethrow;
    }
  }

  /// Save quiz result
  Future<void> saveQuizResult({
    required String token,
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    int? timeTaken,
  }) async {
    try {
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

      debugPrint('Save result response: ${response.statusCode}');

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
      debugPrint('❌ Save result error: $e');
      rethrow;
    }
  }

  /// Get quiz history (all attempts)
  Future<List<Map<String, dynamic>>> getQuizHistory({
    required String token,
  }) async {
    try {
      debugPrint('📜 Fetching quiz history...');

      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/quiz/results'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Get history response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final history = List<Map<String, dynamic>>.from(data);
        debugPrint('✅ Fetched ${history.length} history records');
        return history;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch history');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Fetch history error: $e');
      rethrow;
    }
  }
}
