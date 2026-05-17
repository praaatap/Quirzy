import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../appwrite_client.dart';

/// Analytics Service - Track user progress and insights
class AnalyticsService {
  static AnalyticsService? _instance;
  final Databases _db = AppwriteClient.instance.databases;

  factory AnalyticsService() {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  AnalyticsService._internal();

  /// Save study session
  Future<void> saveStudySession({
    required String userId,
    required String sessionType, // 'quiz' or 'flashcard'
    required int duration,
    required int xpEarned,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: 'study_sessions',
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'sessionType': sessionType,
          'duration': duration,
          'xpEarned': xpEarned,
          'metadata': metadata ?? {},
          'completedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('AnalyticsService: Save session error: $e');
    }
  }

  /// Get study time analytics
  Future<Map<String, dynamic>> getStudyTimeAnalytics({
    required String userId,
    int days = 30,
  }) async {
    try {
      final fromDate = DateTime.now().subtract(Duration(days: days));
      
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: 'study_sessions',
        queries: [
          Query.equal('userId', userId),
          Query.greaterThanEqual('completedAt', fromDate.toIso8601String()),
        ],
      );

      final sessions = result.documents;
      final totalSessions = sessions.length;
      final totalDuration = sessions.fold<int>(
        0,
        (sum, doc) => sum + (doc.data['duration'] as int),
      );
      final totalXP = sessions.fold<int>(
        0,
        (sum, doc) => sum + (doc.data['xpEarned'] as int),
      );

      // Calculate daily average
      final dailyAverage = totalSessions > 0 ? totalDuration / days : 0;

      return {
        'totalSessions': totalSessions,
        'totalDurationMinutes': totalDuration,
        'totalXP': totalXP,
        'dailyAverageMinutes': dailyAverage.roundToDouble(),
        'sessions': sessions.map((doc) => doc.data).toList(),
      };
    } catch (e) {
      debugPrint('AnalyticsService: Get analytics error: $e');
      return {};
    }
  }
}
