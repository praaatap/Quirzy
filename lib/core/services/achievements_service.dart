import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Achievements Service - Tracks user achievements and badges
/// Works completely offline with local storage
class AchievementsService {
  static final AchievementsService _instance = AchievementsService._internal();
  factory AchievementsService() => _instance;
  AchievementsService._internal();

  Box? _box;

  // Keys
  static const String _unlockedAchievementsKey = 'unlocked_achievements';
  static const String _progressKey = 'achievement_progress';
  static const String _newAchievementsKey = 'new_achievements';

  /// All available achievements
  static final List<Achievement> allAchievements = [
    // Quiz Achievements
    Achievement(
      id: 'first_quiz',
      name: 'First Steps',
      description: 'Complete your first quiz',
      icon: '🎯',
      category: AchievementCategory.quiz,
      requirement: 1,
    ),
    Achievement(
      id: 'quiz_10',
      name: 'Quiz Enthusiast',
      description: 'Complete 10 quizzes',
      icon: '📝',
      category: AchievementCategory.quiz,
      requirement: 10,
    ),
    Achievement(
      id: 'quiz_50',
      name: 'Quiz Master',
      description: 'Complete 50 quizzes',
      icon: '🏆',
      category: AchievementCategory.quiz,
      requirement: 50,
    ),
    Achievement(
      id: 'quiz_100',
      name: 'Quiz Legend',
      description: 'Complete 100 quizzes',
      icon: '👑',
      category: AchievementCategory.quiz,
      requirement: 100,
    ),
    Achievement(
      id: 'perfect_score',
      name: 'Perfectionist',
      description: 'Get a perfect score on any quiz',
      icon: '💯',
      category: AchievementCategory.quiz,
      requirement: 1,
    ),
    Achievement(
      id: 'perfect_5',
      name: 'Flawless Five',
      description: 'Get 5 perfect scores',
      icon: '⭐',
      category: AchievementCategory.quiz,
      requirement: 5,
    ),
    Achievement(
      id: 'hard_quiz',
      name: 'Challenge Accepted',
      description: 'Complete a hard difficulty quiz',
      icon: '🔥',
      category: AchievementCategory.quiz,
      requirement: 1,
    ),

    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'Warming Up',
      description: 'Maintain a 3-day streak',
      icon: '🔥',
      category: AchievementCategory.streak,
      requirement: 3,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '📅',
      category: AchievementCategory.streak,
      requirement: 7,
    ),
    Achievement(
      id: 'streak_14',
      name: 'Fortnight Focus',
      description: 'Maintain a 14-day streak',
      icon: '💪',
      category: AchievementCategory.streak,
      requirement: 14,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      icon: '🌟',
      category: AchievementCategory.streak,
      requirement: 30,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Century Club',
      description: 'Maintain a 100-day streak',
      icon: '💎',
      category: AchievementCategory.streak,
      requirement: 100,
    ),

    // Flashcard Achievements
    Achievement(
      id: 'first_flashcard',
      name: 'Memory Starter',
      description: 'Create your first flashcard set',
      icon: '🃏',
      category: AchievementCategory.flashcard,
      requirement: 1,
    ),
    Achievement(
      id: 'flashcard_100',
      name: 'Card Collector',
      description: 'Create 100 flashcards',
      icon: '📚',
      category: AchievementCategory.flashcard,
      requirement: 100,
    ),
    Achievement(
      id: 'flashcard_500',
      name: 'Knowledge Bank',
      description: 'Create 500 flashcards',
      icon: '🏦',
      category: AchievementCategory.flashcard,
      requirement: 500,
    ),
    Achievement(
      id: 'mastered_set',
      name: 'Set Master',
      description: 'Master a flashcard set (100% mastery)',
      icon: '✨',
      category: AchievementCategory.flashcard,
      requirement: 1,
    ),

    // XP Achievements
    Achievement(
      id: 'xp_100',
      name: 'XP Starter',
      description: 'Earn 100 XP',
      icon: '⚡',
      category: AchievementCategory.xp,
      requirement: 100,
    ),
    Achievement(
      id: 'xp_1000',
      name: 'XP Hunter',
      description: 'Earn 1000 XP',
      icon: '💫',
      category: AchievementCategory.xp,
      requirement: 1000,
    ),
    Achievement(
      id: 'xp_5000',
      name: 'XP Champion',
      description: 'Earn 5000 XP',
      icon: '🏅',
      category: AchievementCategory.xp,
      requirement: 5000,
    ),
    Achievement(
      id: 'xp_10000',
      name: 'XP Legend',
      description: 'Earn 10000 XP',
      icon: '👑',
      category: AchievementCategory.xp,
      requirement: 10000,
    ),

    // Rank Achievements
    Achievement(
      id: 'rank_silver',
      name: 'Rising Star',
      description: 'Reach Silver rank',
      icon: '🥈',
      category: AchievementCategory.rank,
      requirement: 1,
    ),
    Achievement(
      id: 'rank_gold',
      name: 'Golden Touch',
      description: 'Reach Gold rank',
      icon: '🥇',
      category: AchievementCategory.rank,
      requirement: 1,
    ),
    Achievement(
      id: 'rank_platinum',
      name: 'Platinum Player',
      description: 'Reach Platinum rank',
      icon: '💎',
      category: AchievementCategory.rank,
      requirement: 1,
    ),
    Achievement(
      id: 'rank_diamond',
      name: 'Diamond Destiny',
      description: 'Reach Diamond rank',
      icon: '💠',
      category: AchievementCategory.rank,
      requirement: 1,
    ),
    Achievement(
      id: 'rank_master',
      name: 'Grandmaster',
      description: 'Reach Master rank',
      icon: '🏆',
      category: AchievementCategory.rank,
      requirement: 1,
    ),
    Achievement(
      id: 'rank_legend',
      name: 'Living Legend',
      description: 'Reach Legend rank',
      icon: '🌟',
      category: AchievementCategory.rank,
      requirement: 1,
    ),

    // Special Achievements
    Achievement(
      id: 'daily_challenge',
      name: 'Daily Challenger',
      description: 'Complete your first daily challenge',
      icon: '🎯',
      category: AchievementCategory.special,
      requirement: 1,
    ),
    Achievement(
      id: 'daily_challenge_7',
      name: 'Challenge Champion',
      description: 'Complete 7 daily challenges',
      icon: '🏆',
      category: AchievementCategory.special,
      requirement: 7,
    ),
    Achievement(
      id: 'offline_player',
      name: 'Offline Scholar',
      description: 'Complete a quiz while offline',
      icon: '📴',
      category: AchievementCategory.special,
      requirement: 1,
    ),
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Study between 12 AM and 5 AM',
      icon: '🦉',
      category: AchievementCategory.special,
      requirement: 1,
    ),
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Study before 6 AM',
      icon: '🌅',
      category: AchievementCategory.special,
      requirement: 1,
    ),
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete a quiz in under 2 minutes',
      icon: '⚡',
      category: AchievementCategory.special,
      requirement: 1,
    ),
  ];

  /// Initialize
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('achievements');
    debugPrint('🏆 Achievements Service initialized');
  }

  /// Get unlocked achievement IDs
  Set<String> getUnlockedAchievementIds() {
    if (_box == null) return {};
    final list = _box!.get(_unlockedAchievementsKey, defaultValue: <dynamic>[]);
    return Set<String>.from((list as List).map((e) => e as String));
  }

  /// Check if achievement is unlocked
  bool isUnlocked(String achievementId) {
    return getUnlockedAchievementIds().contains(achievementId);
  }

  /// Get achievement progress
  int getProgress(String achievementId) {
    if (_box == null) return 0;
    final key = '$_progressKey:$achievementId';
    return _box!.get(key, defaultValue: 0);
  }

  /// Update achievement progress
  Future<Achievement?> updateProgress({
    required String achievementId,
    required int progress,
  }) async {
    if (_box == null) await initialize();

    final key = '$_progressKey:$achievementId';
    final currentProgress = _box!.get(key, defaultValue: 0);
    final newProgress = currentProgress + progress;
    await _box!.put(key, newProgress);

    // Check if unlocked
    try {
      final achievement = allAchievements.firstWhere(
        (a) => a.id == achievementId,
      );
      if (newProgress >= achievement.requirement &&
          !isUnlocked(achievementId)) {
        await _unlockAchievement(achievementId);
        return achievement;
      }
    } catch (e) {
      debugPrint('Achievement not found: $achievementId');
    }

    return null;
  }

  /// Set progress to specific value (for rank achievements)
  Future<Achievement?> setProgress({
    required String achievementId,
    required int progress,
  }) async {
    if (_box == null) await initialize();

    final key = '$_progressKey:$achievementId';
    await _box!.put(key, progress);

    // Check if unlocked
    try {
      final achievement = allAchievements.firstWhere(
        (a) => a.id == achievementId,
      );
      if (progress >= achievement.requirement && !isUnlocked(achievementId)) {
        await _unlockAchievement(achievementId);
        return achievement;
      }
    } catch (e) {
      debugPrint('Achievement not found: $achievementId');
    }

    return null;
  }

  /// Unlock achievement directly
  Future<void> _unlockAchievement(String achievementId) async {
    final unlocked = getUnlockedAchievementIds();
    if (unlocked.contains(achievementId)) return;

    unlocked.add(achievementId);
    await _box!.put(_unlockedAchievementsKey, unlocked.toList());

    // Add to new achievements for notification
    final newList = _box!.get(_newAchievementsKey, defaultValue: <dynamic>[]);
    (newList as List).add(achievementId);
    await _box!.put(_newAchievementsKey, newList);

    debugPrint('🏆 Achievement unlocked: $achievementId');
  }

  /// Get new achievements (and clear them)
  List<Achievement> getNewAchievements() {
    if (_box == null) return [];

    final newList = _box!.get(_newAchievementsKey, defaultValue: <dynamic>[]);
    if ((newList as List).isEmpty) return [];

    // Clear new achievements
    _box!.put(_newAchievementsKey, <dynamic>[]);

    // Return achievement objects
    return (newList)
        .map(
          (id) => allAchievements.cast<Achievement?>().firstWhere(
            (a) => a?.id == id,
            orElse: () => null,
          ),
        )
        .whereType<Achievement>()
        .toList();
  }

  /// Check if there are new achievements
  bool hasNewAchievements() {
    if (_box == null) return false;
    final newList = _box!.get(_newAchievementsKey, defaultValue: <dynamic>[]);
    return (newList as List).isNotEmpty;
  }

  /// Get all achievements with progress
  List<AchievementWithProgress> getAllAchievementsWithProgress() {
    return allAchievements.map((a) {
      return AchievementWithProgress(
        achievement: a,
        progress: getProgress(a.id),
        isUnlocked: isUnlocked(a.id),
      );
    }).toList();
  }

  /// Get achievements by category
  List<AchievementWithProgress> getAchievementsByCategory(
    AchievementCategory category,
  ) {
    return getAllAchievementsWithProgress()
        .where((a) => a.achievement.category == category)
        .toList();
  }

  /// Get unlocked count
  int getUnlockedCount() => getUnlockedAchievementIds().length;

  /// Get total count
  int getTotalCount() => allAchievements.length;

  /// Get completion percentage
  double getCompletionPercentage() {
    if (allAchievements.isEmpty) return 0;
    return getUnlockedCount() / getTotalCount() * 100;
  }

  // ==========================================
  // QUICK CHECK METHODS
  // ==========================================

  /// Check quiz-related achievements
  Future<List<Achievement>> checkQuizAchievements({
    required int totalQuizzes,
    required int perfectScores,
    bool isHardDifficulty = false,
    bool isOffline = false,
    int? timeTakenSeconds,
  }) async {
    final unlocked = <Achievement>[];

    // Quiz count achievements
    final quizAchievements = ['first_quiz', 'quiz_10', 'quiz_50', 'quiz_100'];
    for (final id in quizAchievements) {
      final result = await setProgress(
        achievementId: id,
        progress: totalQuizzes,
      );
      if (result != null) unlocked.add(result);
    }

    // Perfect score achievements
    final perfectAchievements = ['perfect_score', 'perfect_5'];
    for (final id in perfectAchievements) {
      final result = await setProgress(
        achievementId: id,
        progress: perfectScores,
      );
      if (result != null) unlocked.add(result);
    }

    // Hard quiz
    if (isHardDifficulty) {
      final result = await setProgress(achievementId: 'hard_quiz', progress: 1);
      if (result != null) unlocked.add(result);
    }

    // Offline
    if (isOffline) {
      final result = await setProgress(
        achievementId: 'offline_player',
        progress: 1,
      );
      if (result != null) unlocked.add(result);
    }

    // Speed demon (under 2 minutes)
    if (timeTakenSeconds != null && timeTakenSeconds < 120) {
      final result = await setProgress(
        achievementId: 'speed_demon',
        progress: 1,
      );
      if (result != null) unlocked.add(result);
    }

    // Time-based achievements
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 5) {
      final result = await setProgress(achievementId: 'night_owl', progress: 1);
      if (result != null) unlocked.add(result);
    }
    if (hour < 6) {
      final result = await setProgress(
        achievementId: 'early_bird',
        progress: 1,
      );
      if (result != null) unlocked.add(result);
    }

    return unlocked;
  }

  /// Check streak achievements
  Future<List<Achievement>> checkStreakAchievements(int currentStreak) async {
    final unlocked = <Achievement>[];

    final streakAchievements = [
      'streak_3',
      'streak_7',
      'streak_14',
      'streak_30',
      'streak_100',
    ];
    for (final id in streakAchievements) {
      final result = await setProgress(
        achievementId: id,
        progress: currentStreak,
      );
      if (result != null) unlocked.add(result);
    }

    return unlocked;
  }

  /// Check XP achievements
  Future<List<Achievement>> checkXPAchievements(int totalXP) async {
    final unlocked = <Achievement>[];

    final xpAchievements = ['xp_100', 'xp_1000', 'xp_5000', 'xp_10000'];
    for (final id in xpAchievements) {
      final result = await setProgress(achievementId: id, progress: totalXP);
      if (result != null) unlocked.add(result);
    }

    return unlocked;
  }
}

/// Achievement category
enum AchievementCategory { quiz, streak, flashcard, xp, rank, special }

/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int requirement;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirement,
  });
}

/// Achievement with progress
class AchievementWithProgress {
  final Achievement achievement;
  final int progress;
  final bool isUnlocked;

  AchievementWithProgress({
    required this.achievement,
    required this.progress,
    required this.isUnlocked,
  });

  double get progressPercent {
    if (achievement.requirement <= 0) return 100;
    return (progress / achievement.requirement * 100).clamp(0, 100);
  }
}
