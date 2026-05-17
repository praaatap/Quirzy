import 'package:share_plus/share_plus.dart';

/// Feature 10: Progress Sharing Service
/// Share quiz achievements and results
class ProgressSharingService {
  static ProgressSharingService? _instance;

  factory ProgressSharingService() {
    _instance ??= ProgressSharingService._internal();
    return _instance!;
  }

  ProgressSharingService._internal();

  /// Share quiz result
  Future<void> shareQuizResult({
    required String topic,
    required int score,
    required int totalQuestions,
    required int xpEarned,
    required String rank,
  }) async {
    final percentage = (score / totalQuestions * 100).round();
    
    final message = '''
🎯 Quirzy Quiz Result 🎯

📚 Topic: $topic
✅ Score: $score/$totalQuestions ($percentage%)
⭐ XP Earned: $xpEarned
🏆 Rank: $rank

${_getMotivationalMessage(percentage)}

#Quirzy #Learning #Quiz
''';

    await Share.share(message);
  }

  /// Share achievement
  Future<void> shareAchievement({
    required String achievementName,
    required String achievementIcon,
    required int streak,
  }) async {
    final message = '''
$achievementIcon Achievement Unlocked! $achievementIcon

🏆 $achievementName
🔥 Current Streak: $streak days

Keep learning, keep growing! 🌟

#Quirzy #Achievement #Learning
''';

    await Share.share(message);
  }

  /// Share study streak
  Future<void> shareStudyStreak({
    required int streak,
    required int totalXP,
  }) async {
    final message = '''
🔥 $streak Day Study Streak! 🔥

⭐ Total XP: $totalXP
📚 Learning never stops!

Join me on Quirzy and start your learning journey! 🚀

#Quirzy #StudyStreak #Education
''';

    await Share.share(message);
  }

  String _getMotivationalMessage(int percentage) {
    if (percentage == 100) return '🌟 Perfect score! Amazing!';
    if (percentage >= 80) return '💪 Excellent work!';
    if (percentage >= 60) return '👍 Good job! Keep practicing!';
    return '📚 Practice makes perfect!';
  }
}
