import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/quiz_history_provider.dart';

// ==========================================
// USER STATS STATE
// ==========================================

class UserStatsState {
  final int currentStreak;
  final int totalXP;
  final int totalQuizzes;
  final Map<DateTime, int> activityHeatmap;
  final bool isLoading;

  const UserStatsState({
    this.currentStreak = 0,
    this.totalXP = 0,
    this.totalQuizzes = 0,
    this.activityHeatmap = const {},
    this.isLoading = true,
  });

  UserStatsState copyWith({
    int? currentStreak,
    int? totalXP,
    int? totalQuizzes,
    Map<DateTime, int>? activityHeatmap,
    bool? isLoading,
  }) {
    return UserStatsState(
      currentStreak: currentStreak ?? this.currentStreak,
      totalXP: totalXP ?? this.totalXP,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      activityHeatmap: activityHeatmap ?? this.activityHeatmap,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ==========================================
// USER STATS PROVIDER
// ==========================================

final userStatsProvider = NotifierProvider<UserStatsNotifier, UserStatsState>(
  UserStatsNotifier.new,
);

class UserStatsNotifier extends Notifier<UserStatsState> {
  @override
  UserStatsState build() {
    // Listen to history changes to re-calculate stats automatically
    final historyState = ref.watch(quizHistoryProvider);

    if (historyState.isLoading && historyState.quizzes.isEmpty) {
      return const UserStatsState(isLoading: true);
    }

    return _calculateStats(historyState.quizzes);
  }

  UserStatsState _calculateStats(List<Map<String, dynamic>> quizzes) {
    if (quizzes.isEmpty) {
      return const UserStatsState(isLoading: false);
    }

    // 1. Calculate XP (10 XP per point score)
    // Assuming 'score' is the number of correct answers
    int xp = 0;
    for (final quiz in quizzes) {
      final score = (quiz['score'] as int?) ?? 0;
      xp += score * 10;
    }

    // 2. Prepare Activity Data for Streak & Heatmap
    // We need a set of dates where at least one quiz was completed
    final activityDates = <DateTime>{};
    final heatmap = <DateTime, int>{};

    for (final quiz in quizzes) {
      final dateStr = quiz['completedAt'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          // Normalize to midnight for accurate day comparison
          final normalizedDate = DateTime(date.year, date.month, date.day);
          activityDates.add(normalizedDate);

          // Heatmap: count quizzes per day
          heatmap[normalizedDate] = (heatmap[normalizedDate] ?? 0) + 1;
        }
      }
    }

    // 3. Calculate Streak
    // Sort dates descending (newest first)
    final sortedDates = activityDates.toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    if (sortedDates.isNotEmpty) {
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final yesterdayNormalized = todayNormalized.subtract(
        const Duration(days: 1),
      );

      // Check if the most recent activity was today or yesterday to perform a "live" streak check
      // If the last activity was before yesterday, the streak is broken (0).

      final lastActiveDate = sortedDates.first;

      if (lastActiveDate.isAtSameMomentAs(todayNormalized) ||
          lastActiveDate.isAtSameMomentAs(yesterdayNormalized)) {
        // Valid streak start. Now count backwards.
        streak = 1;
        DateTime expectedPrevDate = lastActiveDate.subtract(
          const Duration(days: 1),
        );

        for (int i = 1; i < sortedDates.length; i++) {
          if (sortedDates[i].isAtSameMomentAs(expectedPrevDate)) {
            streak++;
            expectedPrevDate = expectedPrevDate.subtract(
              const Duration(days: 1),
            );
          } else {
            break; // Streak broken
          }
        }
      } else {
        streak = 0;
      }
    }

    return UserStatsState(
      currentStreak: streak,
      totalXP: xp,
      totalQuizzes: quizzes.length,
      activityHeatmap: heatmap,
      isLoading: false,
    );
  }
}
