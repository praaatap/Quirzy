import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AdService - Manages ad display and free quiz limits
class AdService {
  static AdService? _instance;
  static const int _freeQuizLimit = 3;
  int _quizCount = 0;
  bool _initialized = false;

  factory AdService() {
    _instance ??= AdService._internal();
    return _instance!;
  }

  AdService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _quizCount = prefs.getInt('daily_quiz_count') ?? 0;

    // Reset count if it's a new day
    final lastDate = prefs.getString('last_quiz_date');
    final today = DateTime.now().toIso8601String().split('T').first;
    if (lastDate != today) {
      _quizCount = 0;
      await prefs.setString('last_quiz_date', today);
      await prefs.setInt('daily_quiz_count', 0);
    }
    _initialized = true;
  }

  bool isLimitReached() => _quizCount >= _freeQuizLimit;

  int getRemainingFreeQuizzes() =>
      (_freeQuizLimit - _quizCount).clamp(0, _freeQuizLimit);

  void incrementQuizCount() async {
    _quizCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_quiz_count', _quizCount);
  }

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
  }) {
    // TODO: Integrate with google_mobile_ads for production
    // For now, just reward the user
    onRewardEarned();
  }

  bool isFlashcardLimitReached() => false;
  void incrementFlashcardCount() {}
}

/// DailyRewardSheet - Shows daily login reward
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🎉 Day $day Streak!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You earned $xpReward XP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onClaim();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B13EC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Claim Reward',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// QuizGenerationLoadingScreen - Shows while quiz is being generated
class QuizGenerationLoadingScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const QuizGenerationLoadingScreen({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Color(0xFF5B13EC),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Generating Quiz...',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'AI is crafting questions for you',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// StudyInputScreen - For deep study input
class StudyInputScreen extends StatelessWidget {
  const StudyInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Mode')),
      body: const Center(child: Text('Study Input Screen - Coming Soon')),
    );
  }
}
