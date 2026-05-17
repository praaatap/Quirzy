/// Data model for storing quiz session performance data
/// Used by the AI Performance Analyzer to identify patterns

class QuizSessionData {
  final String sessionId;
  final String quizId;
  final String topic;
  final String? difficulty;
  final DateTime timestamp;
  final int totalQuestions;
  final int correctAnswers;
  final List<QuestionPerformance> questionPerformances;
  final int totalTimeSeconds;

  QuizSessionData({
    required this.sessionId,
    required this.quizId,
    required this.topic,
    this.difficulty,
    required this.timestamp,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questionPerformances,
    required this.totalTimeSeconds,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  double get averageTimePerQuestion =>
      totalQuestions > 0 ? totalTimeSeconds / totalQuestions : 0;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'quizId': quizId,
    'topic': topic,
    'difficulty': difficulty,
    'timestamp': timestamp.toIso8601String(),
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'questionPerformances': questionPerformances
        .map((q) => q.toJson())
        .toList(),
    'totalTimeSeconds': totalTimeSeconds,
  };

  factory QuizSessionData.fromJson(Map<String, dynamic> json) =>
      QuizSessionData(
        sessionId: json['sessionId'] as String,
        quizId: json['quizId'] as String,
        topic: json['topic'] as String,
        difficulty: json['difficulty'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        questionPerformances: (json['questionPerformances'] as List)
            .map((q) => QuestionPerformance.fromJson(q))
            .toList(),
        totalTimeSeconds: json['totalTimeSeconds'] as int,
      );
}

class QuestionPerformance {
  final int questionIndex;
  final bool isCorrect;
  final int timeSpentSeconds;
  final String? category; // Sub-topic if available
  final bool usedPowerUp;

  QuestionPerformance({
    required this.questionIndex,
    required this.isCorrect,
    required this.timeSpentSeconds,
    this.category,
    this.usedPowerUp = false,
  });

  Map<String, dynamic> toJson() => {
    'questionIndex': questionIndex,
    'isCorrect': isCorrect,
    'timeSpentSeconds': timeSpentSeconds,
    'category': category,
    'usedPowerUp': usedPowerUp,
  };

  factory QuestionPerformance.fromJson(Map<String, dynamic> json) =>
      QuestionPerformance(
        questionIndex: json['questionIndex'] as int,
        isCorrect: json['isCorrect'] as bool,
        timeSpentSeconds: json['timeSpentSeconds'] as int,
        category: json['category'] as String?,
        usedPowerUp: json['usedPowerUp'] as bool? ?? false,
      );
}
