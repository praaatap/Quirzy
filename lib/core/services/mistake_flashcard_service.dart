import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Mistake to Flashcard Service - Converts wrong quiz answers to flashcards
///
/// Philosophy: The best way to learn is from your mistakes.
/// Every wrong answer becomes a flashcard opportunity.
///
/// Creates the powerful loop: Quiz → Mistake → Flashcard → Mastery
class MistakeFlashcardService {
  static final MistakeFlashcardService _instance =
      MistakeFlashcardService._internal();
  factory MistakeFlashcardService() => _instance;
  MistakeFlashcardService._internal();

  Box? _box;

  // Keys
  static const String _mistakeCardsKey = 'mistake_flashcards';
  static const String _statsKey = 'mistake_stats';

  /// Initialize
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('mistake_flashcards');
    debugPrint('🎯 Mistake Flashcard Service initialized');
  }

  /// Process quiz results and create flashcards from mistakes
  Future<List<MistakeFlashcard>> processQuizMistakes({
    required String quizId,
    required String quizTitle,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    required List<bool> correctAnswers,
  }) async {
    if (_box == null) await initialize();

    final newCards = <MistakeFlashcard>[];

    for (int i = 0; i < questions.length; i++) {
      // Only create flashcard for wrong answers
      if (correctAnswers[i] == false) {
        final question = questions[i];
        final options = (question['options'] as List<dynamic>?) ?? [];
        final correctAnswerIndex = question['correctAnswer'] ?? 0;
        final userAnswerIndex = userSelectedAnswers[i];

        // Get the correct answer text
        String correctAnswerText = '';
        if (correctAnswerIndex >= 0 && correctAnswerIndex < options.length) {
          correctAnswerText = options[correctAnswerIndex].toString();
        }

        // Get user's wrong answer text
        String userWrongAnswer = '';
        if (userAnswerIndex >= 0 && userAnswerIndex < options.length) {
          userWrongAnswer = options[userAnswerIndex].toString();
        }

        // Create flashcard
        final card = MistakeFlashcard(
          id: '${quizId}_mistake_$i',
          quizId: quizId,
          quizTitle: quizTitle,
          question: question['questionText']?.toString() ?? '',
          correctAnswer: correctAnswerText,
          yourWrongAnswer: userWrongAnswer,
          explanation: question['explanation']?.toString(),
          createdAt: DateTime.now(),
          reviewCount: 0,
          mastered: false,
        );

        newCards.add(card);
        await _saveCard(card);
      }
    }

    // Update stats
    await _updateStats(newCards.length);

    if (newCards.isNotEmpty) {
      debugPrint('📝 Created ${newCards.length} flashcards from mistakes');
    }

    return newCards;
  }

  /// Save a flashcard
  Future<void> _saveCard(MistakeFlashcard card) async {
    final cards = _getAllCards();

    // Avoid duplicates (same question from same quiz)
    cards.removeWhere((c) => c.id == card.id);
    cards.add(card);

    // Keep only last 200 mistake cards
    if (cards.length > 200) {
      cards.removeRange(0, cards.length - 200);
    }

    await _box!.put(_mistakeCardsKey, cards.map((c) => c.toMap()).toList());
  }

  /// Get all mistake flashcards
  List<MistakeFlashcard> getAllMistakeCards() {
    return _getAllCards();
  }

  List<MistakeFlashcard> _getAllCards() {
    if (_box == null) return [];
    final raw = _box!.get(_mistakeCardsKey, defaultValue: <dynamic>[]);
    return (raw as List)
        .map(
          (e) => MistakeFlashcard.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// Get unmastered cards for review
  List<MistakeFlashcard> getCardsForReview({int limit = 10}) {
    final cards = _getAllCards().where((c) => !c.mastered).toList()
      ..sort((a, b) => a.reviewCount.compareTo(b.reviewCount));

    return cards.take(limit).toList();
  }

  /// Get cards by quiz
  List<MistakeFlashcard> getCardsByQuiz(String quizId) {
    return _getAllCards().where((c) => c.quizId == quizId).toList();
  }

  /// Mark card as reviewed
  Future<void> markReviewed(String cardId) async {
    if (_box == null) await initialize();

    final cards = _getAllCards();
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      cards[index] = cards[index].copyWith(
        reviewCount: cards[index].reviewCount + 1,
        lastReviewed: DateTime.now(),
      );
      await _box!.put(_mistakeCardsKey, cards.map((c) => c.toMap()).toList());
    }
  }

  /// Mark card as mastered
  Future<void> markMastered(String cardId) async {
    if (_box == null) await initialize();

    final cards = _getAllCards();
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      cards[index] = cards[index].copyWith(mastered: true);
      await _box!.put(_mistakeCardsKey, cards.map((c) => c.toMap()).toList());
    }
  }

  /// Delete a card
  Future<void> deleteCard(String cardId) async {
    if (_box == null) await initialize();

    final cards = _getAllCards();
    cards.removeWhere((c) => c.id == cardId);
    await _box!.put(_mistakeCardsKey, cards.map((c) => c.toMap()).toList());
  }

  /// Get stats
  MistakeStats getStats() {
    if (_box == null) {
      return MistakeStats(totalMistakes: 0, cardsCreated: 0, cardsMastered: 0);
    }

    final statsMap = _box!.get(_statsKey);
    if (statsMap == null) {
      return MistakeStats(totalMistakes: 0, cardsCreated: 0, cardsMastered: 0);
    }

    return MistakeStats.fromMap(Map<String, dynamic>.from(statsMap as Map));
  }

  Future<void> _updateStats(int newCardsCount) async {
    final current = getStats();
    final updated = MistakeStats(
      totalMistakes: current.totalMistakes + newCardsCount,
      cardsCreated: current.cardsCreated + newCardsCount,
      cardsMastered: _getAllCards().where((c) => c.mastered).length,
    );
    await _box!.put(_statsKey, updated.toMap());
  }

  /// Get count of cards pending review
  int getPendingReviewCount() {
    return _getAllCards().where((c) => !c.mastered).length;
  }

  /// Clear all cards
  Future<void> clearAll() async {
    if (_box == null) await initialize();
    await _box!.delete(_mistakeCardsKey);
    await _box!.delete(_statsKey);
  }
}

/// Mistake Flashcard Model
class MistakeFlashcard {
  final String id;
  final String quizId;
  final String quizTitle;
  final String question;
  final String correctAnswer;
  final String yourWrongAnswer;
  final String? explanation;
  final DateTime createdAt;
  final DateTime? lastReviewed;
  final int reviewCount;
  final bool mastered;

  MistakeFlashcard({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.question,
    required this.correctAnswer,
    required this.yourWrongAnswer,
    this.explanation,
    required this.createdAt,
    this.lastReviewed,
    required this.reviewCount,
    required this.mastered,
  });

  MistakeFlashcard copyWith({
    String? id,
    String? quizId,
    String? quizTitle,
    String? question,
    String? correctAnswer,
    String? yourWrongAnswer,
    String? explanation,
    DateTime? createdAt,
    DateTime? lastReviewed,
    int? reviewCount,
    bool? mastered,
  }) {
    return MistakeFlashcard(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      yourWrongAnswer: yourWrongAnswer ?? this.yourWrongAnswer,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      mastered: mastered ?? this.mastered,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'question': question,
      'correctAnswer': correctAnswer,
      'yourWrongAnswer': yourWrongAnswer,
      'explanation': explanation,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
      'reviewCount': reviewCount,
      'mastered': mastered,
    };
  }

  factory MistakeFlashcard.fromMap(Map<String, dynamic> map) {
    return MistakeFlashcard(
      id: map['id'] as String,
      quizId: map['quizId'] as String,
      quizTitle: map['quizTitle'] as String,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      yourWrongAnswer: map['yourWrongAnswer'] as String,
      explanation: map['explanation'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'] as String)
          : null,
      reviewCount: map['reviewCount'] as int,
      mastered: map['mastered'] as bool,
    );
  }
}

/// Stats for mistake tracking
class MistakeStats {
  final int totalMistakes;
  final int cardsCreated;
  final int cardsMastered;

  MistakeStats({
    required this.totalMistakes,
    required this.cardsCreated,
    required this.cardsMastered,
  });

  double get masteryRate =>
      cardsCreated > 0 ? (cardsMastered / cardsCreated) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'totalMistakes': totalMistakes,
      'cardsCreated': cardsCreated,
      'cardsMastered': cardsMastered,
    };
  }

  factory MistakeStats.fromMap(Map<String, dynamic> map) {
    return MistakeStats(
      totalMistakes: map['totalMistakes'] as int,
      cardsCreated: map['cardsCreated'] as int,
      cardsMastered: map['cardsMastered'] as int,
    );
  }
}
