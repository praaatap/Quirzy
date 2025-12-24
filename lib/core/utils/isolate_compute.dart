import 'dart:convert';
import 'package:flutter/foundation.dart';

/// ===========================================
/// ISOLATE COMPUTE UTILITIES
/// ===========================================
/// Provides isolate-based computation for heavy operations
/// to keep the main UI thread responsive.
///
/// This uses Flutter's compute() function which automatically
/// manages isolate creation and communication.

class IsolateCompute {
  /// Size threshold for using isolates (in bytes/length)
  static const int _smallDataThreshold = 10000;
  static const int _smallListThreshold = 50;
  static const int _statsListThreshold = 100;

  // ==========================================
  // JSON PARSING
  // ==========================================

  /// Parse JSON list in a separate isolate (for large datasets)
  /// Automatically falls back to main thread for small data
  static Future<List<Map<String, dynamic>>> parseJsonList(
    String jsonData,
  ) async {
    if (jsonData.length < _smallDataThreshold) {
      return _parseJsonList(jsonData);
    }
    return await compute(_parseJsonList, jsonData);
  }

  /// Static function for isolate execution
  static List<Map<String, dynamic>> _parseJsonList(String jsonData) {
    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Parse JSON map in isolate
  static Future<Map<String, dynamic>> parseJsonMap(String jsonData) async {
    if (jsonData.length < _smallDataThreshold) {
      return Map<String, dynamic>.from(jsonDecode(jsonData));
    }
    return await compute(_parseJsonMap, jsonData);
  }

  static Map<String, dynamic> _parseJsonMap(String jsonData) {
    return Map<String, dynamic>.from(jsonDecode(jsonData));
  }

  // ==========================================
  // JSON ENCODING
  // ==========================================

  /// Encode list to JSON in isolate
  static Future<String> encodeJsonList(List<Map<String, dynamic>> data) async {
    if (data.length < _smallListThreshold) {
      return jsonEncode(data);
    }
    return await compute(_encodeJsonList, data);
  }

  static String _encodeJsonList(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  /// Encode map to JSON in isolate
  static Future<String> encodeJsonMap(Map<String, dynamic> data) async {
    if (data.length < _smallListThreshold) {
      return jsonEncode(data);
    }
    return await compute(_encodeJsonMap, data);
  }

  static String _encodeJsonMap(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // ==========================================
  // QUIZ STATS COMPUTATION
  // ==========================================

  /// Compute quiz statistics off the main thread
  static Future<QuizStats> computeQuizStats(
    List<Map<String, dynamic>> quizzes,
  ) async {
    if (quizzes.length < _statsListThreshold) {
      return _computeQuizStats(quizzes);
    }
    return await compute(_computeQuizStats, quizzes);
  }

  static QuizStats _computeQuizStats(List<Map<String, dynamic>> quizzes) {
    int totalCorrect = 0;
    int totalQuestions = 0;
    int bestPercentage = 0;
    int worstPercentage = 100;
    int totalTimeTaken = 0;

    for (final quiz in quizzes) {
      final score = quiz['score'] as int? ?? 0;
      final total =
          quiz['totalQuestions'] as int? ?? quiz['questionCount'] as int? ?? 0;
      final timeTaken = quiz['timeTaken'] as int? ?? 0;

      totalCorrect += score;
      totalQuestions += total;
      totalTimeTaken += timeTaken;

      if (total > 0) {
        final percentage = ((score / total) * 100).round();
        if (percentage > bestPercentage) bestPercentage = percentage;
        if (percentage < worstPercentage) worstPercentage = percentage;
      }
    }

    return QuizStats(
      totalQuizzes: quizzes.length,
      totalCorrect: totalCorrect,
      totalQuestions: totalQuestions,
      avgPercentage: totalQuestions > 0
          ? ((totalCorrect / totalQuestions) * 100).round()
          : 0,
      bestPercentage: quizzes.isEmpty ? 0 : bestPercentage,
      worstPercentage: quizzes.isEmpty ? 0 : worstPercentage,
      totalTimeTaken: totalTimeTaken,
      computedAt: DateTime.now(),
    );
  }

  // ==========================================
  // LIST SORTING
  // ==========================================

  /// Sort quizzes by date in isolate
  static Future<List<Map<String, dynamic>>> sortQuizzesByDate(
    List<Map<String, dynamic>> quizzes, {
    bool descending = true,
  }) async {
    if (quizzes.length < _smallListThreshold) {
      return _sortByDate(_SortParams(quizzes, descending));
    }
    return await compute(_sortByDate, _SortParams(quizzes, descending));
  }

  static List<Map<String, dynamic>> _sortByDate(_SortParams params) {
    final sorted = List<Map<String, dynamic>>.from(params.data);
    sorted.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB =
          DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return params.descending
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    return sorted;
  }

  // ==========================================
  // LIST FILTERING
  // ==========================================

  /// Filter quizzes by topic in isolate
  static Future<List<Map<String, dynamic>>> filterByTopic(
    List<Map<String, dynamic>> quizzes,
    String topic,
  ) async {
    if (quizzes.length < _smallListThreshold) {
      return _filterByTopic(_FilterParams(quizzes, topic));
    }
    return await compute(_filterByTopic, _FilterParams(quizzes, topic));
  }

  static List<Map<String, dynamic>> _filterByTopic(_FilterParams params) {
    final topicLower = params.filterValue.toLowerCase();
    return params.data.where((quiz) {
      final quizTopic = (quiz['topic'] as String?)?.toLowerCase() ?? '';
      return quizTopic.contains(topicLower);
    }).toList();
  }

  /// Search quizzes by query in isolate
  static Future<List<Map<String, dynamic>>> searchQuizzes(
    List<Map<String, dynamic>> quizzes,
    String query,
  ) async {
    if (quizzes.length < _smallListThreshold || query.isEmpty) {
      return _searchQuizzes(_FilterParams(quizzes, query));
    }
    return await compute(_searchQuizzes, _FilterParams(quizzes, query));
  }

  static List<Map<String, dynamic>> _searchQuizzes(_FilterParams params) {
    if (params.filterValue.isEmpty) return params.data;

    final queryLower = params.filterValue.toLowerCase();
    return params.data.where((quiz) {
      final title = (quiz['title'] as String?)?.toLowerCase() ?? '';
      final topic = (quiz['topic'] as String?)?.toLowerCase() ?? '';
      return title.contains(queryLower) || topic.contains(queryLower);
    }).toList();
  }

  // ==========================================
  // DATA TRANSFORMATION
  // ==========================================

  /// Transform raw API data to app format in isolate
  static Future<List<Map<String, dynamic>>> transformQuizData(
    List<dynamic> rawData,
  ) async {
    if (rawData.length < _smallListThreshold) {
      return _transformQuizData(rawData);
    }
    return await compute(_transformQuizData, rawData);
  }

  static List<Map<String, dynamic>> _transformQuizData(List<dynamic> rawData) {
    return rawData.map((item) {
      final data = Map<String, dynamic>.from(item);
      // Add any transformations needed
      return data;
    }).toList();
  }
}

// ==========================================
// HELPER CLASSES
// ==========================================

/// Pre-computed quiz statistics
class QuizStats {
  final int totalQuizzes;
  final int totalCorrect;
  final int totalQuestions;
  final int avgPercentage;
  final int bestPercentage;
  final int worstPercentage;
  final int totalTimeTaken;
  final DateTime computedAt;

  QuizStats({
    required this.totalQuizzes,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.avgPercentage,
    required this.bestPercentage,
    required this.worstPercentage,
    required this.totalTimeTaken,
    required this.computedAt,
  });

  Map<String, dynamic> toJson() => {
    'totalQuizzes': totalQuizzes,
    'totalCorrect': totalCorrect,
    'totalQuestions': totalQuestions,
    'avgPercentage': avgPercentage,
    'bestPercentage': bestPercentage,
    'worstPercentage': worstPercentage,
    'totalTimeTaken': totalTimeTaken,
    'computedAt': computedAt.millisecondsSinceEpoch,
  };

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      totalQuizzes: json['totalQuizzes'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      avgPercentage: json['avgPercentage'] ?? 0,
      bestPercentage: json['bestPercentage'] ?? 0,
      worstPercentage: json['worstPercentage'] ?? 0,
      totalTimeTaken: json['totalTimeTaken'] ?? 0,
      computedAt: DateTime.fromMillisecondsSinceEpoch(
        json['computedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Create an empty stats object
  factory QuizStats.empty() {
    return QuizStats(
      totalQuizzes: 0,
      totalCorrect: 0,
      totalQuestions: 0,
      avgPercentage: 0,
      bestPercentage: 0,
      worstPercentage: 0,
      totalTimeTaken: 0,
      computedAt: DateTime.now(),
    );
  }
}

/// Helper class for passing sort parameters to isolate
class _SortParams {
  final List<Map<String, dynamic>> data;
  final bool descending;

  _SortParams(this.data, this.descending);
}

/// Helper class for passing filter parameters to isolate
class _FilterParams {
  final List<Map<String, dynamic>> data;
  final String filterValue;

  _FilterParams(this.data, this.filterValue);
}
