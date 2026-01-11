import 'package:hive_flutter/hive_flutter.dart';

/// Achievement System
/// Tracks user achievements and unlocks badges
class AchievementService {
  // Achievement IDs
  static const String firstQuiz = 'first_quiz';
  static const String quiz5 = 'quiz_5';
  static const String quiz25 = 'quiz_25';
  static const String quiz100 = 'quiz_100';
  static const String perfectScore = 'perfect_score';
  static const String streak7 = 'streak_7';
  static const String streak30 = 'streak_30';
  static const String flashcardMaster = 'flashcard_master';
  static const String speedDemon = 'speed_demon';
  static const String nightOwl = 'night_owl';

  /// All available achievements
  static final List<Achievement> allAchievements = [
    Achievement(
      id: firstQuiz,
      title: 'First Steps',
      description: 'Complete your first quiz',
      icon: '🎯',
    ),
    Achievement(
      id: quiz5,
      title: 'Getting Started',
      description: 'Complete 5 quizzes',
      icon: '📚',
    ),
    Achievement(
      id: quiz25,
      title: 'Quiz Enthusiast',
      description: 'Complete 25 quizzes',
      icon: '🏆',
    ),
    Achievement(
      id: quiz100,
      title: 'Quiz Master',
      description: 'Complete 100 quizzes',
      icon: '👑',
    ),
    Achievement(
      id: perfectScore,
      title: 'Perfectionist',
      description: 'Get 100% on a quiz',
      icon: '💯',
    ),
    Achievement(
      id: streak7,
      title: 'Week Warrior',
      description: 'Study for 7 days in a row',
      icon: '🔥',
    ),
    Achievement(
      id: streak30,
      title: 'Monthly Master',
      description: 'Study for 30 days in a row',
      icon: '⭐',
    ),
    Achievement(
      id: flashcardMaster,
      title: 'Card Shark',
      description: 'Master 50 flashcards',
      icon: '🃏',
    ),
    Achievement(
      id: speedDemon,
      title: 'Speed Demon',
      description: 'Complete a quiz in under 2 minutes',
      icon: '⚡',
    ),
    Achievement(
      id: nightOwl,
      title: 'Night Owl',
      description: 'Study after midnight',
      icon: '🦉',
    ),
  ];

  /// Get unlocked achievement IDs
  static Set<String> getUnlockedIds() {
    final box = Hive.box<Map>('achievements');
    final data = box.get('unlocked');
    if (data == null) return {};
    return Set<String>.from(data['ids'] ?? []);
  }

  /// Unlock an achievement
  static Future<bool> unlock(String achievementId) async {
    final unlocked = getUnlockedIds();
    if (unlocked.contains(achievementId)) return false;

    unlocked.add(achievementId);
    final box = Hive.box<Map>('achievements');
    await box.put('unlocked', {
      'ids': unlocked.toList(),
      'lastUnlock': achievementId,
      'lastUnlockTime': DateTime.now().toIso8601String(),
    });
    return true;
  }

  /// Check if achievement is unlocked
  static bool isUnlocked(String achievementId) {
    return getUnlockedIds().contains(achievementId);
  }

  /// Get achievement by ID
  static Achievement? getAchievement(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all unlocked achievements
  static List<Achievement> getUnlockedAchievements() {
    final unlockedIds = getUnlockedIds();
    return allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
  }

  /// Get progress (unlocked / total)
  static double getProgress() {
    return getUnlockedIds().length / allAchievements.length;
  }

  /// Check and unlock achievements based on stats
  static Future<List<Achievement>> checkAndUnlock({
    int? quizCount,
    int? streak,
    double? lastScore,
    int? masteredCards,
    int? quizTimeSeconds,
  }) async {
    final newlyUnlocked = <Achievement>[];

    // Quiz count achievements
    if (quizCount != null) {
      if (quizCount >= 1 && await unlock(firstQuiz)) {
        newlyUnlocked.add(getAchievement(firstQuiz)!);
      }
      if (quizCount >= 5 && await unlock(quiz5)) {
        newlyUnlocked.add(getAchievement(quiz5)!);
      }
      if (quizCount >= 25 && await unlock(quiz25)) {
        newlyUnlocked.add(getAchievement(quiz25)!);
      }
      if (quizCount >= 100 && await unlock(quiz100)) {
        newlyUnlocked.add(getAchievement(quiz100)!);
      }
    }

    // Perfect score
    if (lastScore != null && lastScore == 100 && await unlock(perfectScore)) {
      newlyUnlocked.add(getAchievement(perfectScore)!);
    }

    // Streak achievements
    if (streak != null) {
      if (streak >= 7 && await unlock(streak7)) {
        newlyUnlocked.add(getAchievement(streak7)!);
      }
      if (streak >= 30 && await unlock(streak30)) {
        newlyUnlocked.add(getAchievement(streak30)!);
      }
    }

    // Flashcard mastery
    if (masteredCards != null &&
        masteredCards >= 50 &&
        await unlock(flashcardMaster)) {
      newlyUnlocked.add(getAchievement(flashcardMaster)!);
    }

    // Speed demon (under 2 minutes)
    if (quizTimeSeconds != null &&
        quizTimeSeconds < 120 &&
        await unlock(speedDemon)) {
      newlyUnlocked.add(getAchievement(speedDemon)!);
    }

    // Night owl (after midnight)
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5 && await unlock(nightOwl)) {
      newlyUnlocked.add(getAchievement(nightOwl)!);
    }

    return newlyUnlocked;
  }
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
