import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_session_data.dart';
import '../models/learning_insights.dart';

/// Local AI Performance Analyzer
/// Uses rule-based pattern recognition to analyze quiz performance
/// and generate personalized learning insights.
///
/// This analyzer runs entirely on-device with no cloud dependencies.

class PerformanceAnalyzer {
  static const String _sessionsKey = 'quiz_sessions_data';
  static const int _maxStoredSessions = 100;

  // Singleton pattern
  static final PerformanceAnalyzer _instance = PerformanceAnalyzer._internal();
  factory PerformanceAnalyzer() => _instance;
  PerformanceAnalyzer._internal();

  List<QuizSessionData> _sessions = [];
  bool _isInitialized = false;

  /// Initialize the analyzer and load historical data
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);

    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(sessionsJson);
        _sessions = decoded
            .map((s) => QuizSessionData.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _sessions = [];
      }
    }

    _isInitialized = true;
  }

  /// Record a new quiz session
  Future<void> recordSession(QuizSessionData session) async {
    await initialize();

    _sessions.add(session);

    // Keep only last N sessions to manage storage
    if (_sessions.length > _maxStoredSessions) {
      _sessions = _sessions.sublist(_sessions.length - _maxStoredSessions);
    }

    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = json.encode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, sessionsJson);
  }

  /// Generate comprehensive learning insights
  Future<LearningInsights> generateInsights() async {
    await initialize();

    if (_sessions.isEmpty) {
      return _emptyInsights();
    }

    return LearningInsights(
      generatedAt: DateTime.now(),
      overallPerformance: _analyzeOverallPerformance(),
      topicAnalyses: _analyzeTopics(),
      recommendations: _generateRecommendations(),
      studyPatterns: _analyzeStudyPatterns(),
      weakAreas: _identifyWeakAreas(),
    );
  }

  /// Analyze overall performance metrics
  OverallPerformance _analyzeOverallPerformance() {
    if (_sessions.isEmpty) {
      return OverallPerformance(
        averageAccuracy: 0,
        averageTimePerQuestion: 0,
        totalQuizzesTaken: 0,
        totalQuestionsAnswered: 0,
        currentStreak: 0,
        improvementTrend: 0,
        performanceLevel: 'Beginner',
      );
    }

    // Calculate averages
    double totalAccuracy = 0;
    double totalTime = 0;
    int totalQuestions = 0;

    for (final session in _sessions) {
      totalAccuracy += session.accuracy;
      totalTime += session.averageTimePerQuestion;
      totalQuestions += session.totalQuestions;
    }

    final avgAccuracy = totalAccuracy / _sessions.length;
    final avgTime = totalTime / _sessions.length;

    // Calculate improvement trend (compare last 5 vs previous 5)
    double improvementTrend = 0;
    if (_sessions.length >= 10) {
      final recent = _sessions.sublist(_sessions.length - 5);
      final older = _sessions.sublist(
        _sessions.length - 10,
        _sessions.length - 5,
      );

      final recentAvg = recent.fold(0.0, (sum, s) => sum + s.accuracy) / 5;
      final olderAvg = older.fold(0.0, (sum, s) => sum + s.accuracy) / 5;

      improvementTrend = recentAvg - olderAvg;
    }

    // Calculate streak
    int streak = _calculateStreak();

    // Determine performance level
    String level = _determinePerformanceLevel(avgAccuracy);

    return OverallPerformance(
      averageAccuracy: avgAccuracy,
      averageTimePerQuestion: avgTime,
      totalQuizzesTaken: _sessions.length,
      totalQuestionsAnswered: totalQuestions,
      currentStreak: streak,
      improvementTrend: improvementTrend,
      performanceLevel: level,
    );
  }

  /// Analyze performance by topic
  List<TopicAnalysis> _analyzeTopics() {
    final Map<String, List<QuizSessionData>> topicSessions = {};

    for (final session in _sessions) {
      final topic = session.topic.toLowerCase().trim();
      topicSessions.putIfAbsent(topic, () => []).add(session);
    }

    final analyses = <TopicAnalysis>[];

    for (final entry in topicSessions.entries) {
      final sessions = entry.value;
      if (sessions.isEmpty) continue;

      final avgAccuracy =
          sessions.fold(0.0, (sum, s) => sum + s.accuracy) / sessions.length;
      final avgTime =
          sessions.fold(0.0, (sum, s) => sum + s.averageTimePerQuestion) /
          sessions.length;
      final totalQuestions = sessions.fold(
        0,
        (sum, s) => sum + s.totalQuestions,
      );

      // Determine trend
      String trend = 'stable';
      if (sessions.length >= 3) {
        final recentAccuracy = sessions.last.accuracy;
        final olderAccuracy = sessions[sessions.length - 3].accuracy;
        if (recentAccuracy > olderAccuracy + 5) {
          trend = 'improving';
        } else if (recentAccuracy < olderAccuracy - 5) {
          trend = 'declining';
        }
      }

      analyses.add(
        TopicAnalysis(
          topic: _capitalizeWords(entry.key),
          accuracy: avgAccuracy,
          questionsAttempted: totalQuestions,
          averageTime: avgTime,
          trend: trend,
          isStrength: avgAccuracy >= 75,
          isWeakness: avgAccuracy < 50,
        ),
      );
    }

    // Sort by accuracy (weakest first for priority)
    analyses.sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return analyses;
  }

  /// Analyze study patterns
  StudyPatterns _analyzeStudyPatterns() {
    if (_sessions.length < 5) {
      return StudyPatterns(isConsistent: false, averageSessionsPerWeek: 0);
    }

    // Analyze best time of day
    final Map<int, List<double>> hourAccuracies = {};
    for (final session in _sessions) {
      final hour = session.timestamp.hour;
      hourAccuracies.putIfAbsent(hour, () => []).add(session.accuracy);
    }

    int? bestHour;
    double bestHourAccuracy = 0;
    for (final entry in hourAccuracies.entries) {
      if (entry.value.length >= 2) {
        final avgAccuracy =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avgAccuracy > bestHourAccuracy) {
          bestHourAccuracy = avgAccuracy;
          bestHour = entry.key;
        }
      }
    }

    // Analyze best day of week
    final Map<int, List<double>> dayAccuracies = {};
    for (final session in _sessions) {
      final day = session.timestamp.weekday;
      dayAccuracies.putIfAbsent(day, () => []).add(session.accuracy);
    }

    String? bestDay;
    double bestDayAccuracy = 0;
    final dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    for (final entry in dayAccuracies.entries) {
      if (entry.value.length >= 2) {
        final avgAccuracy =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avgAccuracy > bestDayAccuracy) {
          bestDayAccuracy = avgAccuracy;
          bestDay = dayNames[entry.key];
        }
      }
    }

    // Calculate sessions per week
    if (_sessions.length < 2) {
      return StudyPatterns(
        bestHourOfDay: bestHour,
        bestDayOfWeek: bestDay,
        isConsistent: false,
        averageSessionsPerWeek: _sessions.length,
      );
    }

    final firstSession = _sessions.first.timestamp;
    final lastSession = _sessions.last.timestamp;
    final weeks = lastSession.difference(firstSession).inDays / 7;
    final sessionsPerWeek = weeks > 0
        ? _sessions.length / weeks
        : _sessions.length.toDouble();

    // Determine consistency
    bool isConsistent = sessionsPerWeek >= 3;

    return StudyPatterns(
      bestHourOfDay: bestHour,
      bestDayOfWeek: bestDay,
      optimalSessionLength: 15, // Can be enhanced with actual data
      isConsistent: isConsistent,
      averageSessionsPerWeek: sessionsPerWeek.round(),
    );
  }

  /// Identify weak areas that need improvement
  List<WeakArea> _identifyWeakAreas() {
    final topicAnalyses = _analyzeTopics();
    final weakAreas = <WeakArea>[];
    int priority = 1;

    for (final analysis in topicAnalyses) {
      if (analysis.isWeakness) {
        String reason;
        String suggestion;

        if (analysis.accuracy < 30) {
          reason = 'Very low accuracy indicates fundamental gaps';
          suggestion = 'Start with basics and gradually increase difficulty';
        } else if (analysis.accuracy < 50) {
          reason = 'Below average performance needs attention';
          suggestion = 'Practice more questions and review explanations';
        } else {
          continue; // Not a weak area
        }

        if (analysis.trend == 'declining') {
          reason = 'Performance is declining in this area';
          suggestion = 'Focus on this topic before moving to others';
        }

        weakAreas.add(
          WeakArea(
            topic: analysis.topic,
            reason: reason,
            accuracy: analysis.accuracy,
            suggestion: suggestion,
            priority: priority++,
          ),
        );
      }
    }

    return weakAreas;
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    final overall = _analyzeOverallPerformance();
    final patterns = _analyzeStudyPatterns();
    final weakAreas = _identifyWeakAreas();

    // Based on accuracy
    if (overall.averageAccuracy < 50) {
      recommendations.add(
        '📚 Focus on understanding concepts before attempting more quizzes',
      );
    } else if (overall.averageAccuracy < 70) {
      recommendations.add(
        '🎯 You\'re making good progress! Try harder difficulty levels',
      );
    } else if (overall.averageAccuracy >= 85) {
      recommendations.add(
        '⭐ Excellent performance! Challenge yourself with expert-level content',
      );
    }

    // Based on time
    if (overall.averageTimePerQuestion < 5) {
      recommendations.add(
        '⏱️ You might be rushing - take more time to read questions carefully',
      );
    } else if (overall.averageTimePerQuestion > 45) {
      recommendations.add(
        '⚡ Try to improve your speed while maintaining accuracy',
      );
    }

    // Based on weak areas
    if (weakAreas.isNotEmpty) {
      final topWeak = weakAreas.first;
      recommendations.add(
        '🔍 Priority: Focus on ${topWeak.topic} - ${topWeak.suggestion}',
      );
    }

    // Based on consistency
    if (!patterns.isConsistent) {
      recommendations.add(
        '📅 Try to maintain a regular study schedule for better retention',
      );
    }

    // Based on improvement trend
    if (overall.improvementTrend > 5) {
      recommendations.add(
        '📈 Great job! Your performance is improving - keep it up!',
      );
    } else if (overall.improvementTrend < -5) {
      recommendations.add(
        '💪 Don\'t give up! Take breaks and revisit challenging topics',
      );
    }

    // Based on best study time
    if (patterns.bestHourOfDay != null) {
      recommendations.add(
        '🕐 You perform best at ${patterns.bestTimeDescription}',
      );
    }

    return recommendations;
  }

  /// Calculate current streak (consecutive days with quizzes)
  int _calculateStreak() {
    if (_sessions.isEmpty) return 0;

    final sessions = List.of(_sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 1;
    DateTime lastDate = DateTime(
      sessions.first.timestamp.year,
      sessions.first.timestamp.month,
      sessions.first.timestamp.day,
    );

    // Check if last session was today or yesterday
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final diff = todayStart.difference(lastDate).inDays;

    if (diff > 1) return 0; // Streak broken

    for (int i = 1; i < sessions.length; i++) {
      final sessionDate = DateTime(
        sessions[i].timestamp.year,
        sessions[i].timestamp.month,
        sessions[i].timestamp.day,
      );

      final dayDiff = lastDate.difference(sessionDate).inDays;

      if (dayDiff == 1) {
        streak++;
        lastDate = sessionDate;
      } else if (dayDiff > 1) {
        break;
      }
    }

    return streak;
  }

  /// Determine performance level based on accuracy
  String _determinePerformanceLevel(double accuracy) {
    if (accuracy >= 90) return 'Expert';
    if (accuracy >= 75) return 'Advanced';
    if (accuracy >= 50) return 'Intermediate';
    return 'Beginner';
  }

  /// Capitalize first letter of each word
  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  /// Return empty insights for new users
  LearningInsights _emptyInsights() {
    return LearningInsights(
      generatedAt: DateTime.now(),
      overallPerformance: OverallPerformance(
        averageAccuracy: 0,
        averageTimePerQuestion: 0,
        totalQuizzesTaken: 0,
        totalQuestionsAnswered: 0,
        currentStreak: 0,
        improvementTrend: 0,
        performanceLevel: 'Beginner',
      ),
      topicAnalyses: [],
      recommendations: [
        '🚀 Complete your first quiz to start getting personalized insights!',
        '📊 The more quizzes you take, the better recommendations you\'ll receive',
      ],
      studyPatterns: StudyPatterns(
        isConsistent: false,
        averageSessionsPerWeek: 0,
      ),
      weakAreas: [],
    );
  }

  /// Get number of stored sessions
  int get sessionCount => _sessions.length;

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    _sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }
}
