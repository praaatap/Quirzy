import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../appwrite_client.dart';

/// Quiz Service - Complete quiz operations with Appwrite
/// 
/// Features:
/// - Save quiz results
/// - Get quiz history
/// - Track quiz analytics
/// - Manage quiz attempts
class QuizService {
  static QuizService? _instance;
  final Databases _db = AppwriteClient.instance.databases;

  factory QuizService() {
    _instance ??= QuizService._internal();
    return _instance!;
  }

  QuizService._internal();

  // ==========================================
  // QUIZ RESULT OPERATIONS
  // ==========================================

  /// Save quiz result
  Future<String> saveQuizResult({
    required String userId,
    required String quizId,
    required String topic,
    required int score,
    required int totalQuestions,
    required int timeTaken,
    required String difficulty,
    required Map<String, dynamic> userAnswers,
    int? xpEarned,
    bool? isPerfectScore,
    bool? isDailyChallenge,
  }) async {
    try {
      final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0;
      
      final result = await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'quizId': quizId,
          'topic': topic,
          'score': score,
          'totalQuestions': totalQuestions,
          'percentage': percentage,
          'timeTaken': timeTaken,
          'difficulty': difficulty,
          'userAnswers': userAnswers,
          'xpEarned': xpEarned ?? 0,
          'isPerfectScore': isPerfectScore ?? (percentage == 100),
          'isDailyChallenge': isDailyChallenge ?? false,
          'completedAt': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('QuizService: Saved quiz result - $topic ($percentage%)');
      return result.$id;
    } catch (e) {
      debugPrint('QuizService: Save quiz result error: $e');
      rethrow;
    }
  }

  /// Get quiz result by ID
  Future<Map<String, dynamic>> getQuizResult({required String resultId}) async {
    try {
      final document = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        documentId: resultId,
      );
      return document.data;
    } catch (e) {
      debugPrint('QuizService: Get quiz result error: $e');
      rethrow;
    }
  }

  // ==========================================
  // QUIZ HISTORY
  // ==========================================

  /// Get user's quiz history
  Future<List<Map<String, dynamic>>> getQuizHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
    String? topic,
    String? difficulty,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queries = <String>[
        Query.equal('userId', userId),
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('completedAt'),
      ];

      if (topic != null) {
        queries.add(Query.equal('topic', topic));
      }
      if (difficulty != null) {
        queries.add(Query.equal('difficulty', difficulty));
      }
      if (fromDate != null) {
        queries.add(Query.greaterThanEqual('completedAt', fromDate.toIso8601String()));
      }
      if (toDate != null) {
        queries.add(Query.lessThanEqual('completedAt', toDate.toIso8601String()));
      }

      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        queries: queries,
      );

      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      debugPrint('QuizService: Get quiz history error: $e');
      return [];
    }
  }

  /// Get quiz statistics for user
  Future<Map<String, dynamic>> getQuizStatistics({required String userId}) async {
    try {
      final history = await getQuizHistory(userId: userId, limit: 1000);
      
      if (history.isEmpty) {
        return {
          'totalQuizzes': 0,
          'averageScore': 0.0,
          'perfectScores': 0,
          'totalQuestions': 0,
          'totalXP': 0,
          'bestStreak': 0,
          'favoriteTopics': [],
          'difficultyBreakdown': {},
        };
      }

      final totalQuizzes = history.length;
      final averageScore = history.fold<double>(
        0.0,
        (sum, quiz) => sum + (quiz['percentage'] as num).toDouble(),
      ) / totalQuizzes;
      
      final perfectScores = history.where((q) => q['isPerfectScore'] == true).length;
      final totalQuestions = history.fold<int>(
        0,
        (sum, quiz) => sum + (quiz['totalQuestions'] as int),
      );
      
      final totalXP = history.fold<int>(
        0,
        (sum, quiz) => sum + (quiz['xpEarned'] as int),
      );

      // Calculate favorite topics
      final topicCounts = <String, int>{};
      for (final quiz in history) {
        final topic = quiz['topic'] as String;
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }
      
      final favoriteTopics = topicCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Difficulty breakdown
      final difficultyBreakdown = <String, int>{};
      for (final quiz in history) {
        final difficulty = quiz['difficulty'] as String;
        difficultyBreakdown[difficulty] = (difficultyBreakdown[difficulty] ?? 0) + 1;
      }

      return {
        'totalQuizzes': totalQuizzes,
        'averageScore': averageScore.roundToDouble(),
        'perfectScores': perfectScores,
        'totalQuestions': totalQuestions,
        'totalXP': totalXP,
        'favoriteTopics': favoriteTopics.take(5).map((e) => e.key).toList(),
        'difficultyBreakdown': difficultyBreakdown,
      };
    } catch (e) {
      debugPrint('QuizService: Get statistics error: $e');
      return {};
    }
  }

  // ==========================================
  // QUIZ ANALYTICS
  // ==========================================

  /// Get topic-wise performance
  Future<Map<String, dynamic>> getTopicPerformance({
    required String userId,
    required String topic,
  }) async {
    try {
      final history = await getQuizHistory(userId: userId, topic: topic, limit: 100);
      
      if (history.isEmpty) {
        return {
          'topic': topic,
          'attempts': 0,
          'averageScore': 0.0,
          'bestScore': 0,
          'worstScore': 0,
          'lastScore': 0,
          'improvement': 0.0,
          'timeSpent': 0,
        };
      }

      final scores = history.map((q) => q['percentage'] as int).toList();
      final averageScore = scores.fold<int>(0, (a, b) => a + b) / scores.length;
      
      // Calculate improvement (compare first 3 vs last 3)
      double improvement = 0.0;
      if (scores.length >= 6) {
        final first3Avg = scores.sublist(scores.length - 3).fold<int>(0, (a, b) => a + b) / 3;
        final last3Avg = scores.sublist(0, 3).fold<int>(0, (a, b) => a + b) / 3;
        improvement = first3Avg - last3Avg;
      }

      final timeSpent = history.fold<int>(
        0,
        (sum, quiz) => sum + (quiz['timeTaken'] as int),
      );

      return {
        'topic': topic,
        'attempts': history.length,
        'averageScore': averageScore.roundToDouble(),
        'bestScore': scores.reduce((a, b) => a > b ? a : b),
        'worstScore': scores.reduce((a, b) => a < b ? a : b),
        'lastScore': scores.first,
        'improvement': improvement.roundToDouble(),
        'timeSpent': timeSpent,
      };
    } catch (e) {
      debugPrint('QuizService: Get topic performance error: $e');
      return {};
    }
  }

  /// Get weak areas (topics with lowest scores)
  Future<List<Map<String, dynamic>>> getWeakAreas({required String userId}) async {
    try {
      final history = await getQuizHistory(userId: userId, limit: 200);
      
      final topicStats = <String, List<int>>{};
      for (final quiz in history) {
        final topic = quiz['topic'] as String;
        final score = quiz['percentage'] as int;
        topicStats.putIfAbsent(topic, () => []).add(score);
      }

      final weakAreas = topicStats.entries.map((entry) {
        final scores = entry.value;
        final average = scores.fold<int>(0, (a, b) => a + b) / scores.length;
        final attempts = scores.length;
        
        return {
          'topic': entry.key,
          'averageScore': average.roundToDouble(),
          'attempts': attempts,
          'needsImprovement': average < 60,
        };
      }).toList();

      weakAreas.sort((a, b) => (a['averageScore'] as num).compareTo(b['averageScore'] as num));
      
      return weakAreas.where((area) => area['needsImprovement'] == true).toList();
    } catch (e) {
      debugPrint('QuizService: Get weak areas error: $e');
      return [];
    }
  }

  // ==========================================
  // QUIZ MANAGEMENT
  // ==========================================

  /// Delete quiz result
  Future<void> deleteQuizResult({required String resultId}) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.quizResultsCollection,
        documentId: resultId,
      );
    } catch (e) {
      debugPrint('QuizService: Delete quiz result error: $e');
      rethrow;
    }
  }

  /// Clear all quiz history for user
  Future<void> clearQuizHistory({required String userId}) async {
    try {
      final history = await getQuizHistory(userId: userId, limit: 1000);
      
      for (final quiz in history) {
        final id = quiz['\$id'] as String?;
        if (id != null) {
          await _db.deleteDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.quizResultsCollection,
            documentId: id,
          );
        }
      }
      
      debugPrint('QuizService: Cleared ${history.length} quiz results');
    } catch (e) {
      debugPrint('QuizService: Clear quiz history error: $e');
      rethrow;
    }
  }

  /// Get recent quizzes (last 5)
  Future<List<Map<String, dynamic>>> getRecentQuizzes({required String userId}) async {
    return await getQuizHistory(userId: userId, limit: 5);
  }

  /// Get quizzes by difficulty
  Future<List<Map<String, dynamic>>> getQuizzesByDifficulty({
    required String userId,
    required String difficulty,
  }) async {
    return await getQuizHistory(userId: userId, difficulty: difficulty, limit: 50);
  }
}
