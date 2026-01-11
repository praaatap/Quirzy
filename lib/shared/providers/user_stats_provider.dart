import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  final int currentStreak;
  final int totalXP;
  final DateTime? lastStudyDate;
  final int totalQuizzes;
  final int totalFlashcards;

  const UserStats({
    this.currentStreak = 0,
    this.totalXP = 0,
    this.lastStudyDate,
    this.totalQuizzes = 0,
    this.totalFlashcards = 0,
  });

  UserStats copyWith({
    int? currentStreak,
    int? totalXP,
    DateTime? lastStudyDate,
    int? totalQuizzes,
    int? totalFlashcards,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      totalXP: totalXP ?? this.totalXP,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalFlashcards: totalFlashcards ?? this.totalFlashcards,
    );
  }
}

class UserStatsNotifier extends AsyncNotifier<UserStats> {
  static const String _keyStreak = 'stats_streak';
  static const String _keyXP = 'stats_xp';
  static const String _keyLastDate = 'stats_last_date';
  static const String _keyQuizzes = 'stats_total_quizzes';
  static const String _keyFlashcards = 'stats_total_flashcards';

  @override
  Future<UserStats> build() async {
    return _loadStats();
  }

  Future<UserStats> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_keyStreak) ?? 0;
    final xp = prefs.getInt(_keyXP) ?? 0;
    final quizzes = prefs.getInt(_keyQuizzes) ?? 0;
    final flashcards = prefs.getInt(_keyFlashcards) ?? 0;
    final lastDateStr = prefs.getString(_keyLastDate);

    DateTime? lastDate;
    if (lastDateStr != null) {
      lastDate = DateTime.tryParse(lastDateStr);
    }

    // Check daily streak
    var tempStats = UserStats(
      currentStreak: streak,
      totalXP: xp,
      lastStudyDate: lastDate,
      totalQuizzes: quizzes,
      totalFlashcards: flashcards,
    );

    tempStats = await _checkStreak(tempStats, prefs);
    return tempStats;
  }

  Future<UserStats> _checkStreak(
    UserStats currentStats,
    SharedPreferences prefs,
  ) async {
    if (currentStats.lastStudyDate == null) return currentStats;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      currentStats.lastStudyDate!.year,
      currentStats.lastStudyDate!.month,
      currentStats.lastStudyDate!.day,
    );

    final difference = today.difference(last).inDays;

    if (difference > 1) {
      // Streak broken
      await prefs.setInt(_keyStreak, 0);
      return currentStats.copyWith(currentStreak: 0);
    }
    return currentStats;
  }

  Future<void> addXP(int amount) async {
    final currentState = state.value;
    if (currentState == null) return;

    final prefs = await SharedPreferences.getInstance();
    final newXP = currentState.totalXP + amount;

    await prefs.setInt(_keyXP, newXP);
    state = AsyncData(currentState.copyWith(totalXP: newXP));
  }

  Future<void> incrementQuizCount() async {
    final currentState = state.value;
    if (currentState == null) return;

    final prefs = await SharedPreferences.getInstance();
    final newCount = currentState.totalQuizzes + 1;

    await prefs.setInt(_keyQuizzes, newCount);

    final updatedStats = currentState.copyWith(totalQuizzes: newCount);
    await _updateDailyStreak(updatedStats, prefs);
  }

  Future<void> incrementFlashcardCount() async {
    final currentState = state.value;
    if (currentState == null) return;

    final prefs = await SharedPreferences.getInstance();
    final newCount = currentState.totalFlashcards + 1;

    await prefs.setInt(_keyFlashcards, newCount);

    final updatedStats = currentState.copyWith(totalFlashcards: newCount);
    await _updateDailyStreak(updatedStats, prefs);
  }

  Future<void> _updateDailyStreak(
    UserStats currentStats,
    SharedPreferences prefs,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = currentStats.currentStreak;

    if (currentStats.lastStudyDate == null) {
      // First time
      newStreak = 1;
    } else {
      final last = DateTime(
        currentStats.lastStudyDate!.year,
        currentStats.lastStudyDate!.month,
        currentStats.lastStudyDate!.day,
      );

      if (today.isAfter(last)) {
        final difference = today.difference(last).inDays;

        if (difference == 1) {
          // Continued streak
          newStreak++;
        } else {
          // Broken streak, restart
          newStreak = 1;
        }
      }
      // If today == last, streak stays same
    }

    await prefs.setInt(_keyStreak, newStreak);
    await prefs.setString(_keyLastDate, now.toIso8601String());

    state = AsyncData(
      currentStats.copyWith(currentStreak: newStreak, lastStudyDate: now),
    );
  }
}

final userStatsProvider = AsyncNotifierProvider<UserStatsNotifier, UserStats>(
  () {
    return UserStatsNotifier();
  },
);
