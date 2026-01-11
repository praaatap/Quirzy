import 'package:share_plus/share_plus.dart';

/// Quiz Sharing Service
/// Generates shareable quiz results
class ShareService {
  /// Share quiz result
  static Future<void> shareQuizResult({
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required double percentage,
    int? timeTaken,
  }) async {
    final emoji = _getScoreEmoji(percentage);
    final timeStr = timeTaken != null ? _formatTime(timeTaken) : null;

    final text =
        '''
$emoji Quiz Complete! $emoji

📚 $quizTitle
✅ Score: $score/$totalQuestions (${percentage.round()}%)
${timeStr != null ? '⏱️ Time: $timeStr\n' : ''}
🎯 Can you beat my score?

#Quirzy #QuizApp #Learning
''';

    await Share.share(text, subject: 'My Quirzy Quiz Result!');
  }

  /// Share flashcard progress
  static Future<void> shareFlashcardProgress({
    required String setTitle,
    required int masteredCards,
    required int totalCards,
    required int streak,
  }) async {
    final percentage = (masteredCards / totalCards * 100).round();

    final text =
        '''
📚 Flashcard Progress Update!

🃏 $setTitle
✅ Mastered: $masteredCards/$totalCards ($percentage%)
🔥 Study Streak: $streak days

#Quirzy #StudyWithMe #Learning
''';

    await Share.share(text, subject: 'My Flashcard Progress!');
  }

  /// Share achievement unlock
  static Future<void> shareAchievement({
    required String title,
    required String description,
    required String icon,
  }) async {
    final text =
        '''
🏆 Achievement Unlocked!

$icon $title
$description

#Quirzy #Achievement #Learning
''';

    await Share.share(text, subject: 'I unlocked an achievement on Quirzy!');
  }

  /// Get emoji based on score
  static String _getScoreEmoji(double percentage) {
    if (percentage == 100) return '🏆';
    if (percentage >= 90) return '🌟';
    if (percentage >= 80) return '🎉';
    if (percentage >= 70) return '👍';
    if (percentage >= 60) return '📈';
    return '💪';
  }

  /// Format time in mm:ss
  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}
