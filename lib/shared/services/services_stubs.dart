import 'package:flutter/material.dart';

// --------------------------------------------------------------------------
// EXISTING STUBS (keep synced or merge if needed, mostly for other files)
// --------------------------------------------------------------------------

export 'achievement_service.dart' show Achievement;
// import 'achievement_service.dart' show Achievement; // Not needed if we don't use it here directly

class GameEffectsService {
  void successVibration() {}
  void lightTap() {}
  void rankUpCelebration() {}
}

class OfflineQuizManager {
  Future<void> addToPracticePool(List<Map<String, dynamic>> questions) async {}
  Future<void> saveLastQuizInfo({
    required String quizId,
    required String title,
    required String topic,
    required List<Map<String, dynamic>> questions,
    required int score,
    required int totalQuestions,
    required String? difficulty,
  }) async {}

  Future<void> saveQuizForOffline({
    required String quizId,
    required String title,
    required List<Map<String, dynamic>> questions,
    required String? difficulty,
  }) async {}
}

class MistakeFlashcardService {
  Future<void> processQuizMistakes({
    required String quizId,
    required String quizTitle,
    required List<Map<String, dynamic>> questions,
    required List<int> userSelectedAnswers,
    required List<bool> correctAnswers,
  }) async {}
}

class AchievementsService {
  // Assuming proper type is handled in actual service or we stub generic
  Future<List<dynamic>> checkQuizAchievements({
    required int totalQuizzes,
    required int perfectScores,
    required bool isHardDifficulty,
  }) async {
    return [];
  }
}

class ShareableResultCard {
  static void shareResult({
    required BuildContext context,
    required String quizTitle,
    required int score,
    required int totalQuestions,
  }) {}
}

// --------------------------------------------------------------------------
// NEW STUBS FOR FLASHCARDS SCREEN
// --------------------------------------------------------------------------

class AdService {
  bool isFlashcardLimitReached() => false;
  bool isLimitReached() => false;
  int getRemainingFreeQuizzes() => 3;
  void incrementFlashcardCount() {}
  void incrementQuizCount() {}
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
  }) {
    // Stub
    onRewardEarned();
  }
}

class FlashcardCacheService {
  static Future<void> init() async {}
}

class FlashcardService {
  static Future<List<Map<String, dynamic>>> getFlashcardSets({
    bool forceRefresh = false,
  }) async {
    return [];
  }

  static Future<Map<String, dynamic>> generateFlashcards(
    String topic, {
    int cardCount = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'id': 'stub_id', 'title': topic, 'cards': <Map<String, dynamic>>[]};
  }

  static Future<Map<String, dynamic>> getFlashcardSet(String id) async {
    return {'id': id, 'title': 'Stub Set', 'cards': <Map<String, dynamic>>[]};
  }
}

class ShimmerPlaceholders {
  static Widget historyList({int itemCount = 3}) => Container();
}

class QuizGenerationLoadingScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const QuizGenerationLoadingScreen({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Loading stub...')));
}

class FlashcardStudyScreen extends StatelessWidget {
  final String setId;
  final String title;
  final List<Map<String, dynamic>> cards;
  const FlashcardStudyScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Study study stub')));
}

class DailyRewardSheet extends StatelessWidget {
  final int day;
  final int xpReward;
  final VoidCallback onClaim;

  const DailyRewardSheet({
    super.key,
    required this.day,
    required this.xpReward,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StartQuizScreen extends StatelessWidget {
  final String quizId;
  final String quizTitle;
  final List<Map<String, dynamic>> questions;
  const StartQuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StudyInputScreen extends StatelessWidget {
  const StudyInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
