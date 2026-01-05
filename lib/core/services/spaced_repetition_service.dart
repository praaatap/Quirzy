import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Spaced Repetition Service - Smart flashcard review scheduling
///
/// Uses SM-2 algorithm principles for optimal learning:
/// - Cards you struggle with appear more frequently
/// - Cards you know well appear less frequently
/// - Tracks learning progress per card
class SpacedRepetitionService {
  static final SpacedRepetitionService _instance =
      SpacedRepetitionService._internal();
  factory SpacedRepetitionService() => _instance;
  SpacedRepetitionService._internal();

  Box? _box;

  // Keys
  static const String _cardProgressKey = 'card_progress';
  static const String _reviewHistoryKey = 'review_history';

  // SM-2 Parameters
  static const double _minEaseFactor = 1.3;
  static const double _defaultEaseFactor = 2.5;

  /// Initialize
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('spaced_repetition');
    debugPrint('🧠 Spaced Repetition Service initialized');
  }

  // ==========================================
  // CARD PROGRESS TRACKING
  // ==========================================

  /// Get progress for a specific card
  CardProgress getCardProgress(String cardId) {
    if (_box == null) {
      return CardProgress(
        cardId: cardId,
        easeFactor: _defaultEaseFactor,
        interval: 1,
        repetitions: 0,
        nextReview: DateTime.now(),
        lastReview: null,
      );
    }

    final progressMap = _box!.get('$_cardProgressKey:$cardId');
    if (progressMap == null) {
      return CardProgress(
        cardId: cardId,
        easeFactor: _defaultEaseFactor,
        interval: 1,
        repetitions: 0,
        nextReview: DateTime.now(),
        lastReview: null,
      );
    }

    return CardProgress.fromMap(Map<String, dynamic>.from(progressMap as Map));
  }

  /// Save card progress
  Future<void> _saveCardProgress(CardProgress progress) async {
    if (_box == null) await initialize();
    await _box!.put('$_cardProgressKey:${progress.cardId}', progress.toMap());
  }

  /// Record card review result
  /// Quality: 0-2 (wrong), 3-4 (correct with difficulty), 5 (perfect)
  Future<CardProgress> recordReview({
    required String cardId,
    required int quality,
  }) async {
    if (_box == null) await initialize();

    // Clamp quality between 0-5
    final q = quality.clamp(0, 5);
    var progress = getCardProgress(cardId);

    // SM-2 Algorithm
    if (q < 3) {
      // Failed - reset
      progress = progress.copyWith(
        repetitions: 0,
        interval: 1,
        nextReview: DateTime.now().add(const Duration(minutes: 10)),
      );
    } else {
      // Success
      int newInterval;
      if (progress.repetitions == 0) {
        newInterval = 1;
      } else if (progress.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (progress.interval * progress.easeFactor).round();
      }

      // Calculate new ease factor
      double newEaseFactor =
          progress.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      newEaseFactor = newEaseFactor.clamp(_minEaseFactor, 3.0);

      progress = progress.copyWith(
        repetitions: progress.repetitions + 1,
        interval: newInterval,
        easeFactor: newEaseFactor,
        nextReview: DateTime.now().add(Duration(days: newInterval)),
        lastReview: DateTime.now(),
      );
    }

    await _saveCardProgress(progress);
    await _recordToHistory(cardId, quality);

    debugPrint(
      '📝 Card $cardId reviewed (q=$q), next in ${progress.interval} days',
    );
    return progress;
  }

  /// Record easy response (quality 5)
  Future<CardProgress> markEasy(String cardId) =>
      recordReview(cardId: cardId, quality: 5);

  /// Record good response (quality 4)
  Future<CardProgress> markGood(String cardId) =>
      recordReview(cardId: cardId, quality: 4);

  /// Record hard response (quality 3)
  Future<CardProgress> markHard(String cardId) =>
      recordReview(cardId: cardId, quality: 3);

  /// Record wrong response (quality 1)
  Future<CardProgress> markWrong(String cardId) =>
      recordReview(cardId: cardId, quality: 1);

  // ==========================================
  // REVIEW SCHEDULING
  // ==========================================

  /// Get cards due for review from a set
  List<String> getDueCards(List<String> cardIds) {
    if (_box == null) return cardIds;

    final now = DateTime.now();
    final dueCards = <String>[];

    for (final cardId in cardIds) {
      final progress = getCardProgress(cardId);
      if (progress.nextReview.isBefore(now) ||
          progress.nextReview.difference(now).inHours < 1) {
        dueCards.add(cardId);
      }
    }

    return dueCards;
  }

  /// Get priority sorted cards (most due first)
  List<String> getPrioritySortedCards(List<String> cardIds) {
    if (_box == null) return cardIds;

    final sortedCards = List<String>.from(cardIds);
    sortedCards.sort((a, b) {
      final progressA = getCardProgress(a);
      final progressB = getCardProgress(b);
      return progressA.nextReview.compareTo(progressB.nextReview);
    });

    return sortedCards;
  }

  /// Count due cards
  int countDueCards(List<String> cardIds) {
    return getDueCards(cardIds).length;
  }

  // ==========================================
  // HISTORY & STATS
  // ==========================================

  Future<void> _recordToHistory(String cardId, int quality) async {
    final today = _formatDate(DateTime.now());
    final key = '$_reviewHistoryKey:$today';

    final todaysHistory = _box!.get(key, defaultValue: <dynamic>[]);
    final history = List<Map<String, dynamic>>.from(
      (todaysHistory as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    history.add({
      'cardId': cardId,
      'quality': quality,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _box!.put(key, history);
  }

  /// Get today's review count
  int getTodaysReviewCount() {
    if (_box == null) return 0;
    final today = _formatDate(DateTime.now());
    final key = '$_reviewHistoryKey:$today';
    final history = _box!.get(key, defaultValue: <dynamic>[]);
    return (history as List).length;
  }

  /// Get streak of days with reviews
  int getReviewStreak() {
    if (_box == null) return 0;

    int streak = 0;
    var checkDate = DateTime.now();

    while (true) {
      final key = '$_reviewHistoryKey:${_formatDate(checkDate)}';
      final history = _box!.get(key, defaultValue: <dynamic>[]);

      if ((history as List).isEmpty) {
        // Allow one day gap
        if (streak == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          final prevKey = '$_reviewHistoryKey:${_formatDate(checkDate)}';
          final prevHistory = _box!.get(prevKey, defaultValue: <dynamic>[]);
          if ((prevHistory as List).isEmpty) break;
        } else {
          break;
        }
      }

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      // Safety limit
      if (streak > 365) break;
    }

    return streak;
  }

  /// Get mastery stats for a set of cards
  MasteryStats getMasteryStats(List<String> cardIds) {
    if (_box == null || cardIds.isEmpty) {
      return MasteryStats(total: 0, learning: 0, reviewing: 0, mastered: 0);
    }

    int learning = 0;
    int reviewing = 0;
    int mastered = 0;

    for (final cardId in cardIds) {
      final progress = getCardProgress(cardId);

      if (progress.repetitions == 0) {
        learning++;
      } else if (progress.interval < 21) {
        reviewing++;
      } else {
        mastered++;
      }
    }

    return MasteryStats(
      total: cardIds.length,
      learning: learning,
      reviewing: reviewing,
      mastered: mastered,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Card progress data
class CardProgress {
  final String cardId;
  final double easeFactor;
  final int interval; // days
  final int repetitions;
  final DateTime nextReview;
  final DateTime? lastReview;

  CardProgress({
    required this.cardId,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReview,
    this.lastReview,
  });

  CardProgress copyWith({
    String? cardId,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? nextReview,
    DateTime? lastReview,
  }) {
    return CardProgress(
      cardId: cardId ?? this.cardId,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'nextReview': nextReview.toIso8601String(),
      'lastReview': lastReview?.toIso8601String(),
    };
  }

  factory CardProgress.fromMap(Map<String, dynamic> map) {
    return CardProgress(
      cardId: map['cardId'] as String,
      easeFactor: (map['easeFactor'] as num).toDouble(),
      interval: map['interval'] as int,
      repetitions: map['repetitions'] as int,
      nextReview: DateTime.parse(map['nextReview'] as String),
      lastReview: map['lastReview'] != null
          ? DateTime.parse(map['lastReview'] as String)
          : null,
    );
  }

  /// Get human-readable next review time
  String get nextReviewText {
    final now = DateTime.now();
    final diff = nextReview.difference(now);

    if (diff.isNegative || diff.inMinutes < 5) {
      return 'Now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  /// Check if card is due for review
  bool get isDue => nextReview.isBefore(DateTime.now());

  /// Get mastery level (0-100)
  int get masteryLevel {
    if (repetitions == 0) return 0;
    if (interval < 7) return (repetitions * 10).clamp(0, 30);
    if (interval < 21) return (30 + (interval - 7) * 3).clamp(30, 70);
    return (70 + ((interval - 21) / 10 * 30).round()).clamp(70, 100);
  }
}

/// Mastery statistics for a card set
class MasteryStats {
  final int total;
  final int learning; // repetitions == 0
  final int reviewing; // interval < 21 days
  final int mastered; // interval >= 21 days

  MasteryStats({
    required this.total,
    required this.learning,
    required this.reviewing,
    required this.mastered,
  });

  double get learningPercent => total > 0 ? learning / total * 100 : 0;
  double get reviewingPercent => total > 0 ? reviewing / total * 100 : 0;
  double get masteredPercent => total > 0 ? mastered / total * 100 : 0;
}
