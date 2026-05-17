import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

/// Appwrite Configuration
class AppwriteConfig {
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId = '695be801003d58b523fc';
  static const String databaseId = '695d45fe000f2d83ddee';

  // Collections
  static const String quizzesCollection = 'quizzes';
  static const String questionsCollection = 'questions';
  static const String quizResultsCollection = 'quiz_results';

  // Functions
  static const String quizGenerateFunction = 'quiz-generate';
  static const String studyGenerateFunction = 'study-generate';
  static const String challengeManageFunction = 'challenge-manage';

  // Additional collections (used by shared services)
  static const String usersCollection = 'users';
  static const String flashcardsCollection = 'flashcard_sets';
  static const String achievementsCollection = 'achievements';
  static const String leaderboardCollection = 'leaderboard';
  static const String storageId = 'main_storage';

  // Premium feature collections
  static const String mockTestsCollection = 'mock_tests';
  static const String studyMaterialsCollection = 'study_materials';

  // Premium feature functions
  static const String mockTestFunction = 'mock-test-generate';
  static const String studyMaterialFunction = 'study-material-generate';
}

/// Singleton Appwrite Client
class AppwriteClient {
  static AppwriteClient? _instance;
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Functions functions;
  late final Storage storage;

  AppwriteClient._() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId)
        .setSelfSigned(status: kDebugMode);

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
    storage = Storage(client);
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

  // Create Manual Quiz (no AI — user provides questions directly)
  Future<Map<String, dynamic>> createManualQuiz({
    required String title,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final user = await _account.get();
      final now = DateTime.now().toIso8601String();

      final quiz = await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizzesCollection,
        documentId: ID.unique(),
        data: {
          'title': title,
          'userId': user.$id,
          'createdAt': now,
          'updatedAt': now,
        },
      );

      final savedQuestions = <Map<String, dynamic>>[];
      for (int i = 0; i < questions.length; i++) {
        final q = await _db.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.questionsCollection,
          documentId: ID.unique(),
          data: {
            'quizId': quiz.$id,
            'questionText': questions[i]['questionText'] as String,
            'options': List<String>.from(questions[i]['options'] as List),
            'correctAnswer': questions[i]['correctAnswer'] as int,
            'questionNumber': i + 1,
          },
        );
        savedQuestions.add({
          'id': q.$id,
          'questionText': q.data['questionText'],
          'options': List<String>.from(q.data['options'] ?? []),
          'correctAnswer': q.data['correctAnswer'],
          'questionNumber': q.data['questionNumber'],
        });
      }

      return {
        'quizId': quiz.$id,
        'title': quiz.data['title'],
        'questionCount': savedQuestions.length,
        'questions': savedQuestions,
      };
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to create quiz');
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
