/// Model for AI-generated learning insights
/// Contains analysis results and personalized recommendations

class LearningInsights {
  final DateTime generatedAt;
  final OverallPerformance overallPerformance;
  final List<TopicAnalysis> topicAnalyses;
  final List<String> recommendations;
  final StudyPatterns studyPatterns;
  final List<WeakArea> weakAreas;

  LearningInsights({
    required this.generatedAt,
    required this.overallPerformance,
    required this.topicAnalyses,
    required this.recommendations,
    required this.studyPatterns,
    required this.weakAreas,
  });
}

class OverallPerformance {
  final double averageAccuracy;
  final double averageTimePerQuestion;
  final int totalQuizzesTaken;
  final int totalQuestionsAnswered;
  final int currentStreak;
  final double improvementTrend; // Positive = improving, Negative = declining
  final String performanceLevel; // Beginner, Intermediate, Advanced, Expert

  OverallPerformance({
    required this.averageAccuracy,
    required this.averageTimePerQuestion,
    required this.totalQuizzesTaken,
    required this.totalQuestionsAnswered,
    required this.currentStreak,
    required this.improvementTrend,
    required this.performanceLevel,
  });
}

class TopicAnalysis {
  final String topic;
  final double accuracy;
  final int questionsAttempted;
  final double averageTime;
  final String trend; // 'improving', 'stable', 'declining'
  final bool isStrength;
  final bool isWeakness;

  TopicAnalysis({
    required this.topic,
    required this.accuracy,
    required this.questionsAttempted,
    required this.averageTime,
    required this.trend,
    required this.isStrength,
    required this.isWeakness,
  });
}

class StudyPatterns {
  final int? bestHourOfDay; // 0-23
  final String? bestDayOfWeek;
  final double? optimalSessionLength; // in minutes
  final bool isConsistent;
  final int averageSessionsPerWeek;

  StudyPatterns({
    this.bestHourOfDay,
    this.bestDayOfWeek,
    this.optimalSessionLength,
    required this.isConsistent,
    required this.averageSessionsPerWeek,
  });

  String get bestTimeDescription {
    if (bestHourOfDay == null) return 'Not enough data';
    if (bestHourOfDay! < 6) return 'Early Morning (${bestHourOfDay}:00)';
    if (bestHourOfDay! < 12) return 'Morning (${bestHourOfDay}:00)';
    if (bestHourOfDay! < 17) return 'Afternoon (${bestHourOfDay}:00)';
    if (bestHourOfDay! < 21) return 'Evening (${bestHourOfDay}:00)';
    return 'Night (${bestHourOfDay}:00)';
  }
}

class WeakArea {
  final String topic;
  final String reason;
  final double accuracy;
  final String suggestion;
  final int priority; // 1 = highest priority

  WeakArea({
    required this.topic,
    required this.reason,
    required this.accuracy,
    required this.suggestion,
    required this.priority,
  });
}
