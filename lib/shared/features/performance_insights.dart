/// Feature 5: Performance Insights
/// Smart analytics and progress tracking
class PerformanceInsights {
  /// Analyze quiz performance and provide insights
  static Map<String, dynamic> analyzePerformance(List<Map<String, dynamic>> quizHistory) {
    if (quizHistory.isEmpty) {
      return {
        'averageScore': 0.0,
        'trend': 'stable',
        'strongTopics': [],
        'weakTopics': [],
        'bestTime': 'N/A',
        'insights': ['Start taking quizzes to get insights!'],
      };
    }

    final scores = quizHistory.map((q) => q['percentage'] as num).toList();
    final averageScore = scores.fold<num>(0, (a, b) => a + b) / scores.length;

    // Calculate trend (last 5 vs previous 5)
    String trend = 'stable';
    if (scores.length >= 10) {
      final recent5 = scores.sublist(0, 5).fold<num>(0, (a, b) => a + b) / 5;
      final previous5 = scores.sublist(5, 10).fold<num>(0, (a, b) => a + b) / 5;
      final difference = recent5 - previous5;
      
      if (difference > 10) trend = 'improving';
      else if (difference < -10) trend = 'declining';
    }

    // Analyze topics
    final topicScores = <String, List<num>>{};
    for (final quiz in quizHistory) {
      final topic = quiz['topic'] as String;
      final score = quiz['percentage'] as num;
      topicScores.putIfAbsent(topic, () => []).add(score);
    }

    final topicAverages = topicScores.map(
      (topic, scores) => MapEntry(
        topic,
        scores.fold<num>(0, (a, b) => a + b) / scores.length,
      ),
    );

    final sortedTopics = topicAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strongTopics = sortedTopics
        .where((e) => e.value >= 80)
        .map((e) => e.key)
        .toList();
    
    final weakTopics = sortedTopics
        .where((e) => e.value < 60)
        .map((e) => e.key)
        .toList();

    // Generate insights
    final insights = <String>[];
    
    if (averageScore >= 80) {
      insights.add('🌟 Excellent performance! You\'re mastering these topics!');
    } else if (averageScore >= 60) {
      insights.add('💪 Good progress! Keep practicing to improve!');
    } else {
      insights.add('📚 Focus on weak areas to boost your scores!');
    }

    if (trend == 'improving') {
      insights.add('📈 Your scores are trending up! Great work!');
    } else if (trend == 'declining') {
      insights.add('⚠️ Scores trending down. Try reviewing weak areas!');
    }

    if (weakTopics.isNotEmpty) {
      insights.add('🎯 Focus on: ${weakTopics.take(3).join(", ")}');
    }

    return {
      'averageScore': averageScore.roundToDouble(),
      'trend': trend,
      'strongTopics': strongTopics,
      'weakTopics': weakTopics,
      'totalQuizzes': quizHistory.length,
      'insights': insights,
      'topicBreakdown': topicAverages,
    };
  }

  /// Get personalized study recommendations
  static List<String> getStudyRecommendations(Map<String, dynamic> performance) {
    final recommendations = <String>[];
    final weakTopics = performance['weakTopics'] as List<String>;
    final trend = performance['trend'] as String;

    if (weakTopics.isNotEmpty) {
      recommendations.add('Review flashcards for: ${weakTopics.first}');
      recommendations.add('Take more quizzes on weak topics');
    }

    if (trend == 'declining') {
      recommendations.add('Take a break and review basics');
    }

    recommendations.add('Maintain your daily streak for bonus XP');
    recommendations.add('Try the daily challenge for extra rewards');

    return recommendations;
  }
}
