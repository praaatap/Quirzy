import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

/// Appwrite Configuration
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '695be801003d58b523fc';
  static const String databaseId = '695d45fe000f2d83ddee';

  // Collections
  static const String quizzesCollection = 'quizzes';
  static const String questionsCollection = 'questions';
  static const String quizResultsCollection = 'quiz_results';

  // Functions
  static const String quizGenerateFunction = 'quiz-generate';
}

/// Singleton Appwrite Client
class AppwriteClient {
  static AppwriteClient? _instance;
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Functions functions;

  AppwriteClient._() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId)
        .setSelfSigned(status: kDebugMode);

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
  }

  static AppwriteClient get instance {
    _instance ??= AppwriteClient._();
    return _instance!;
  }
}

/// Quiz Service using Appwrite
class QuizService {
  final Databases _db = AppwriteClient.instance.databases;
  final Functions _fn = AppwriteClient.instance.functions;
  final Account _account = AppwriteClient.instance.account;

  // Generate Quiz (calls Appwrite Function)
  Future<Map<String, dynamic>> generateQuiz({
    required String topic,
    int questionCount = 15,
    String difficulty = 'medium',
  }) async {
    try {
      final user = await _account.get();

      final execution = await _fn.createExecution(
        functionId: AppwriteConfig.quizGenerateFunction,
        body: jsonEncode({
          'topic': topic,
          'questionCount': questionCount,
          'difficulty': difficulty,
          'userId': user.$id,
        }),
      );

      if (execution.status.name == 'completed') {
        final response = jsonDecode(execution.responseBody);
        if (response['error'] != null) throw Exception(response['error']);
        return response;
      }
      throw Exception('Quiz generation failed');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to generate quiz');
    }
  }

  // Get My Quizzes
  Future<List<Map<String, dynamic>>> getMyQuizzes() async {
    try {
      final user = await _account.get();
      final response = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizzesCollection,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc('createdAt'),
          Query.limit(20),
        ],
      );

      return response.documents.map((doc) {
        return <String, dynamic>{
          'id': doc.$id,
          'title': doc.data['title'],
          'createdAt': doc.data['createdAt'],
        };
      }).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch quizzes');
    }
  }

  // Get Quiz by ID with Questions
  Future<Map<String, dynamic>> getQuizById(String quizId) async {
    try {
      final quiz = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizzesCollection,
        documentId: quizId,
      );

      final questionsResponse = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.questionsCollection,
        queries: [
          Query.equal('quizId', quizId),
          Query.orderAsc('questionNumber'),
        ],
      );

      return {
        'id': quiz.$id,
        'title': quiz.data['title'],
        'createdAt': quiz.data['createdAt'],
        'questions': questionsResponse.documents.map((doc) {
          return <String, dynamic>{
            'id': doc.$id,
            'questionText': doc.data['questionText'],
            'options': List<String>.from(doc.data['options'] ?? []),
            'correctAnswer': doc.data['correctAnswer'],
            'questionNumber': doc.data['questionNumber'],
          };
        }).toList(),
      };
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Quiz not found');
    }
  }

  // Delete Quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete questions first
      final questions = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.questionsCollection,
        queries: [Query.equal('quizId', quizId)],
      );

      for (final q in questions.documents) {
        await _db.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.questionsCollection,
          documentId: q.$id,
        );
      }

      await _db.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizzesCollection,
        documentId: quizId,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to delete quiz');
    }
  }

  // Save Quiz Result
  Future<void> saveQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> questions,
    required List<int> userAnswers,
    int? timeTaken,
  }) async {
    try {
      final user = await _account.get();
      final percentage = totalQuestions > 0
          ? (score / totalQuestions) * 100
          : 0.0;

      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        documentId: ID.unique(),
        data: {
          'userId': user.$id,
          'quizId': quizId,
          'quizTitle': quizTitle,
          'score': score,
          'totalQuestions': totalQuestions,
          'percentage': percentage,
          'timeTaken': timeTaken ?? 0,
          'questionsJson': jsonEncode(questions),
          'userAnswersJson': jsonEncode(userAnswers),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to save result');
    }
  }

  // Get Quiz History
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      final user = await _account.get();
      final response = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc('createdAt'),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch history');
    }
  }
}
