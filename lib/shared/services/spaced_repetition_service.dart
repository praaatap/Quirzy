import 'package:hive/hive.dart';
import 'dart:math';

/// Spaced Repetition Service
/// Implements SM-2 algorithm for optimal flashcard review scheduling
class SpacedRepetitionService {
  static const String _boxName = 'spaced_repetition';

  /// Get card review data
  static CardReviewData getCardData(String cardId) {
    final box = Hive.box<Map>(_boxName);
    final data = box.get(cardId);
    if (data == null) {
      return CardReviewData(
        cardId: cardId,
        easeFactor: 2.5,
        interval: 1,
        repetitions: 0,
        nextReview: DateTime.now(),
      );
    }
    return CardReviewData.fromMap(Map<String, dynamic>.from(data));
  }

  /// Update card after review using SM-2 algorithm
  static Future<CardReviewData> reviewCard({
    required String cardId,
    required int quality, // 0-5 (0=complete fail, 5=perfect)
  }) async {
    final current = getCardData(cardId);

    // SM-2 Algorithm
    double easeFactor = current.easeFactor;
    int interval = current.interval;
    int repetitions = current.repetitions;

    if (quality < 3) {
      // Failed - reset
      repetitions = 0;
      interval = 1;
    } else {
      // Success - update
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
    }

    // Update ease factor
    easeFactor =
        easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    easeFactor = max(1.3, easeFactor);

    final nextReview = DateTime.now().add(Duration(days: interval));

    final updated = CardReviewData(
      cardId: cardId,
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReview: nextReview,
      lastReview: DateTime.now(),
    );

    // Save
    final box = Hive.box<Map>(_boxName);
    await box.put(cardId, updated.toMap());

    return updated;
  }

  /// Get cards due for review
  static Future<List<String>> getCardsDueForReview(List<String> cardIds) async {
    final now = DateTime.now();
    return cardIds.where((id) {
      final data = getCardData(id);
      return data.nextReview.isBefore(now) ||
          data.nextReview.isAtSameMomentAs(now);
    }).toList();
  }

  /// Get review priority (lower = more urgent)
  static int getReviewPriority(String cardId) {
    final data = getCardData(cardId);
    final daysDue = DateTime.now().difference(data.nextReview).inDays;
    return -daysDue; // Negative so overdue cards have lowest priority number
  }

  /// Sort cards by review priority
  static List<String> sortByPriority(List<String> cardIds) {
    return List<String>.from(cardIds)
      ..sort((a, b) => getReviewPriority(a).compareTo(getReviewPriority(b)));
  }

  /// Get mastery level (0-100)
  static int getMasteryLevel(String cardId) {
    final data = getCardData(cardId);
    // Based on repetitions and ease factor
    final repScore = min(data.repetitions * 10, 50);
    final easeScore = ((data.easeFactor - 1.3) / (3.0 - 1.3) * 50).round();
    return min(100, repScore + easeScore);
  }

  /// Initialize box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }
}

/// Card review data model
class CardReviewData {
  final String cardId;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReview;
  final DateTime? lastReview;

  CardReviewData({
    required this.cardId,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReview,
    this.lastReview,
  });

  factory CardReviewData.fromMap(Map<String, dynamic> map) {
    return CardReviewData(
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
}
