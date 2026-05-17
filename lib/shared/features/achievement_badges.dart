/// Feature 4: Achievement Badges System
/// 30+ unlockable achievement badges
class AchievementBadges {
  static const List<Achievement> allAchievements = [
    // Quiz Achievements
    Achievement(
      id: 'first_quiz',
      name: 'First Steps',
      description: 'Complete your first quiz',
      icon: '🎯',
      xpReward: 50,
      condition: {'type': 'quiz_count', 'value': 1},
    ),
    Achievement(
      id: 'quiz_master',
      name: 'Quiz Master',
      description: 'Complete 50 quizzes',
      icon: '🏆',
      xpReward: 500,
      condition: {'type': 'quiz_count', 'value': 50},
    ),
    Achievement(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Get 100% on a quiz',
      icon: '💯',
      xpReward: 200,
      condition: {'type': 'perfect_score', 'value': 1},
    ),
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete a quiz in under 2 minutes',
      icon: '⚡',
      xpReward: 150,
      condition: {'type': 'speed_quiz', 'value': 120},
    ),
    
    // Streak Achievements
    Achievement(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      xpReward: 300,
      condition: {'type': 'streak', 'value': 7},
    ),
    Achievement(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      icon: '👑',
      xpReward: 1000,
      condition: {'type': 'streak', 'value': 30},
    ),
    Achievement(
      id: 'century_club',
      name: 'Century Club',
      description: 'Maintain a 100-day streak',
      icon: '💎',
      xpReward: 5000,
      condition: {'type': 'streak', 'value': 100},
    ),
    
    // Flashcard Achievements
    Achievement(
      id: 'memory_starter',
      name: 'Memory Starter',
      description: 'Create your first flashcard set',
      icon: '📚',
      xpReward: 50,
      condition: {'type': 'flashcard_count', 'value': 1},
    ),
    Achievement(
      id: 'card_collector',
      name: 'Card Collector',
      description: 'Create 25 flashcard sets',
      icon: '🗂️',
      xpReward: 400,
      condition: {'type': 'flashcard_count', 'value': 25},
    ),
    
    // XP Achievements
    Achievement(
      id: 'xp_hunter',
      name: 'XP Hunter',
      description: 'Earn 5000 XP',
      icon: '⭐',
      xpReward: 300,
      condition: {'type': 'total_xp', 'value': 5000},
    ),
    Achievement(
      id: 'xp_legend',
      name: 'XP Legend',
      description: 'Earn 50000 XP',
      icon: '🌟',
      xpReward: 2000,
      condition: {'type': 'total_xp', 'value': 50000},
    ),
    
    // Special Achievements
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Complete a quiz after midnight',
      icon: '🦉',
      xpReward: 100,
      condition: {'type': 'night_quiz', 'value': 1},
    ),
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a quiz before 6 AM',
      icon: '🐦',
      xpReward: 100,
      condition: {'type': 'early_quiz', 'value': 1},
    ),
    Achievement(
      id: 'polymath',
      name: 'Polymath',
      description: 'Complete quizzes in 10 different topics',
      icon: '🧠',
      xpReward: 600,
      condition: {'type': 'topic_variety', 'value': 10},
    ),
  ];

  /// Check if an achievement is unlocked
  static bool isUnlocked(Achievement achievement, Map<String, dynamic> userStats) {
    final condition = achievement.condition;
    final type = condition['type'] as String;
    final required = condition['value'] as num;

    switch (type) {
      case 'quiz_count':
        return (userStats['totalQuizzes'] ?? 0) >= required;
      case 'perfect_score':
        return (userStats['perfectScores'] ?? 0) >= required;
      case 'streak':
        return (userStats['bestStreak'] ?? 0) >= required;
      case 'flashcard_count':
        return (userStats['totalFlashcards'] ?? 0) >= required;
      case 'total_xp':
        return (userStats['totalXP'] ?? 0) >= required;
      case 'topic_variety':
        return (userStats['uniqueTopics'] ?? 0) >= required;
      default:
        return false;
    }
  }

  /// Get unlocked achievements
  static List<Achievement> getUnlockedAchievements(Map<String, dynamic> userStats) {
    return allAchievements.where((a) => isUnlocked(a, userStats)).toList();
  }

  /// Get locked achievements
  static List<Achievement> getLockedAchiements(Map<String, dynamic> userStats) {
    return allAchievements.where((a) => !isUnlocked(a, userStats)).toList();
  }

  /// Get achievement progress
  static double getAchievementProgress(Achievement achievement, Map<String, dynamic> userStats) {
    final condition = achievement.condition;
    final type = condition['type'] as String;
    final required = condition['value'] as num;

    num current = 0;
    switch (type) {
      case 'quiz_count':
        current = userStats['totalQuizzes'] ?? 0;
        break;
      case 'streak':
        current = userStats['bestStreak'] ?? 0;
        break;
      case 'total_xp':
        current = userStats['totalXP'] ?? 0;
        break;
      default:
        return 0.0;
    }

    return (current / required).clamp(0.0, 1.0);
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final Map<String, dynamic> condition;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.condition,
  });
}
