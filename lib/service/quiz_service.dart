import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/utils/constant.dart';

// Riverpod Provider
final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

class QuizService {
  static const _storage = FlutterSecureStorage();

  // ==================== 1. SAVE QUIZ RESULT (History) ====================
  /// Call this when user finishes a quiz. 
  /// Matches the call signature in QuizCompleteScreen.
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
      debugPrint('📝 Saving quiz result for ID: $quizId');

      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login to save results');

      final bodyData = {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'questions': questions, // Backend stores this as questionsJson
        'userSelectedAnswers': userSelectedAnswers, // Backend stores as userAnswersJson
        'timeTaken': timeTaken ?? 0,
      };

      // Endpoint: POST /quiz/result
      final response = await http.post(
        Uri.parse('$kBackendApiUrl/quiz/result'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyData),
      ).timeout(const Duration(seconds: 20));

      debugPrint('Save result response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Result saved successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save result');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Save result error: $e');
      rethrow;
    }
  }

  // ==================== 2. GET QUIZ HISTORY (Attempts) ====================
  /// Fetches the list of past quiz attempts (with stats and details)
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      debugPrint('📜 Fetching quiz history...');

      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login to view history');

      // Endpoint: GET /quiz/results
      final response = await http.get(
        Uri.parse('$kBackendApiUrl/quiz/results'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Get history response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
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

  // ==================== 3. GET CREATED QUIZZES (Templates) ====================
  /// Fetches quizzes that the user CREATED (not played)
  Future<List<Map<String, dynamic>>> getMyQuizzes() async {
    try {
      debugPrint('📋 Fetching created quizzes...');
      
      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login to view quizzes');

      // Endpoint: GET /quiz/my-quizzes
      final response = await http.get(
        Uri.parse('$kBackendApiUrl/quiz/my-quizzes'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Get my quizzes response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The backend likely returns { quizzes: [...] }
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

  // ==================== 4. GENERATE QUIZ (AI) ====================
  Future<Map<String, dynamic>> generateQuiz(
    String topic, {
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      debugPrint('🎯 Generating quiz for topic: $topic');

      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login to generate quizzes');

      final response = await http.post(
        Uri.parse('$kBackendApiUrl/quiz/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'topic': topic,
          'questionCount': questionCount,
          'difficulty': difficulty,
        }),
      ).timeout(const Duration(seconds: 60)); // AI takes time

      debugPrint('Quiz generation response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Quiz generated successfully. ID: ${data['quizId']}');
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else {
        final errorBody = json.decode(response.body);
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

  // ==================== 5. GENERATE FROM FILE ====================
  Future<Map<String, dynamic>> generateQuizFromFile({
    required File file,
    required String fileType,
    String? topic,
    int questionCount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      debugPrint('📄 Generating quiz from $fileType file');

      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login to generate quizzes');

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

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      debugPrint('📤 Uploading file (${(fileSize / 1024).toStringAsFixed(2)} KB)...');
      
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Quiz from file response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to generate quiz from file');
      }
    } catch (e) {
      debugPrint('❌ Quiz from file error: $e');
      rethrow;
    }
  }

  // ==================== 6. GET SPECIFIC QUIZ ====================
  // Changed ID to String to handle standard string passing in frontend
  Future<Map<String, dynamic>> getQuiz(String quizId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login');

      final response = await http.get(
        Uri.parse('$kBackendApiUrl/quiz/$quizId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch quiz');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== 7. DELETE QUIZ ====================
  // Changed ID to String
  Future<void> deleteQuiz(String quizId) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Please login');

      final response = await http.delete(
        Uri.parse('$kBackendApiUrl/quiz/$quizId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete quiz');
      }
    } catch (e) {
      rethrow;
    }
  }
}