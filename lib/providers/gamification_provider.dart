import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/core/services/rank_service.dart';
import 'package:quirzy/core/services/daily_streak_service.dart';

/// Gamification State
class GamificationState {
  final RankTier currentRank;
  final int totalXP;
  final double progressToNextRank;
  final int xpToNextRank;
  final RankTier? nextRank;
  final int currentStreak;
  final int longestStreak;
  final RankUpResult? pendingRankUp;
  final bool isLoading;

  const GamificationState({
    required this.currentRank,
    required this.totalXP,
    required this.progressToNextRank,
    required this.xpToNextRank,
    this.nextRank,
    required this.currentStreak,
    required this.longestStreak,
    this.pendingRankUp,
    this.isLoading = false,
  });

  GamificationState copyWith({
    RankTier? currentRank,
    int? totalXP,
    double? progressToNextRank,
    int? xpToNextRank,
    RankTier? nextRank,
    int? currentStreak,
    int? longestStreak,
    RankUpResult? pendingRankUp,
    bool? isLoading,
    bool clearPendingRankUp = false,
  }) {
    return GamificationState(
      currentRank: currentRank ?? this.currentRank,
      totalXP: totalXP ?? this.totalXP,
      progressToNextRank: progressToNextRank ?? this.progressToNextRank,
      xpToNextRank: xpToNextRank ?? this.xpToNextRank,
      nextRank: nextRank ?? this.nextRank,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      pendingRankUp: clearPendingRankUp
          ? null
          : (pendingRankUp ?? this.pendingRankUp),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Gamification Notifier - Manages XP, ranks, streaks, and achievements
class GamificationNotifier extends Notifier<GamificationState> {
  final RankService _rankService = RankService();
  final DailyStreakService _streakService = DailyStreakService();

  @override
  GamificationState build() {
    // Initialize services automatically
    _init();

    return GamificationState(
      currentRank: RankService.allRanks.first,
      totalXP: 0,
      progressToNextRank: 0,
      xpToNextRank: 100,
      currentStreak: 0,
      longestStreak: 0,
      isLoading: true,
    );
  }

  Future<void> _init() async {
    await _rankService.initialize();
    await _streakService.initialize();
    await refresh();
  }

  /// Refresh all gamification data
  Future<void> refresh() async {
    state = state.copyWith(
      currentRank: _rankService.getCurrentRank(),
      totalXP: _rankService.getTotalXP(),
      progressToNextRank: _rankService.getProgressToNextRank(),
      xpToNextRank: _rankService.getXPToNextRank(),
      nextRank: _rankService.getNextRank(),
      currentStreak: _streakService.getCurrentStreak(),
      longestStreak: _streakService.getLongestStreak(),
      isLoading: false,
    );
  }

  /// Award XP for completing a quiz
  /// Returns the XP earned and potential rank-up result
  Future<({int xpEarned, RankUpResult? rankUp})> awardQuizXP({
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
    String difficulty = 'medium',
  }) async {
    // Calculate XP based on performance
    int baseXP = 10;

    // Score bonus: up to 50 XP for perfect score
    final scorePercentage = totalQuestions > 0 ? score / totalQuestions : 0;
    final scoreXP = (scorePercentage * 50).round();

    // Difficulty bonus
    int difficultyXP = 0;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        difficultyXP = 5;
        break;
      case 'medium':
        difficultyXP = 15;
        break;
      case 'hard':
        difficultyXP = 30;
        break;
    }

    // Speed bonus: bonus for completing quickly (under 2 min per question avg)
    int speedXP = 0;
    if (totalQuestions > 0) {
      final avgTimePerQuestion = timeTakenSeconds / totalQuestions;
      if (avgTimePerQuestion < 30) {
        speedXP = 20; // Very fast
      } else if (avgTimePerQuestion < 60) {
        speedXP = 10; // Fast
      }
    }

    // Perfect score bonus
    int perfectXP = 0;
    if (scorePercentage == 1.0 && totalQuestions >= 5) {
      perfectXP = 25;
      debugPrint('🎯 Perfect score bonus! +$perfectXP XP');
    }

    final totalXP = baseXP + scoreXP + difficultyXP + speedXP + perfectXP;

    debugPrint(
      '📊 XP Breakdown: Base=$baseXP, Score=$scoreXP, Difficulty=$difficultyXP, Speed=$speedXP, Perfect=$perfectXP',
    );
    debugPrint('✨ Total XP Earned: $totalXP');

    // Add XP to rank system
    final rankUpResult = await _rankService.addXP(totalXP);

    // Refresh state
    await refresh();

    // Store pending rank-up for animation
    if (rankUpResult != null) {
      state = state.copyWith(pendingRankUp: rankUpResult);
    }

    return (xpEarned: totalXP, rankUp: rankUpResult);
  }

  /// Award XP for creating flashcards
  Future<({int xpEarned, RankUpResult? rankUp})> awardFlashcardXP({
    required int cardCount,
  }) async {
    // 2 XP per card, min 10 XP
    final xpEarned = (cardCount * 2).clamp(10, 100);

    debugPrint('📚 Flashcard XP Earned: $xpEarned for $cardCount cards');

    final rankUpResult = await _rankService.addXP(xpEarned);
    await refresh();

    if (rankUpResult != null) {
      state = state.copyWith(pendingRankUp: rankUpResult);
    }

    return (xpEarned: xpEarned, rankUp: rankUpResult);
  }

  /// Clear pending rank-up (after showing animation)
  void clearPendingRankUp() {
    state = state.copyWith(clearPendingRankUp: true);
    _rankService.clearRankUpPending();
  }

  /// Check if there's a pending rank-up to show
  bool get hasPendingRankUp => state.pendingRankUp != null;
}

/// Provider for gamification
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
      GamificationNotifier.new,
    );
