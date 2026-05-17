import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme_config.dart';

/// Shareable Result Card - Beautiful quiz result sharing
class ShareableResultCard extends StatelessWidget {
  final String topic;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final String rank;
  final int streak;
  final GlobalKey _cardKey = GlobalKey();

  ShareableResultCard({
    super.key,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.rank,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0;
    final isPerfect = percentage == 100;
    final isGood = percentage >= 70;

    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPerfect
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : isGood
                    ? [ThemeConfig.primaryColor, ThemeConfig.secondaryColor]
                    : [const Color(0xFF64748B), const Color(0xFF475569)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo/Brand
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, color: Colors.white.withOpacity(0.9), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Quizzy',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isPerfect ? 'PERFECT!' : isGood ? 'GREAT!' : 'GOOD',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Topic
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                topic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Score', '$score/$totalQuestions'),
                _buildStatItem('XP', '+$xpEarned'),
                _buildStatItem('Streak', '$streak 🔥'),
              ],
            ),
            const SizedBox(height: 24),

            // Rank Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rank: $rank',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // CTA
            Text(
              'Join me on Quizzy!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '#Quizzy #Learning #Quiz',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Share as image
  Future<void> shareAsImage(BuildContext context) async {
    try {
      // For now, share as text (image capture requires render context)
      final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0;
      
      final message = '''
🎯 Quizzy Quiz Result 🎯

📚 Topic: $topic
✅ Score: $score/$totalQuestions ($percentage%)
⭐ XP Earned: +$xpEarned
🔥 Streak: $streak days
🏆 Rank: $rank

${percentage == 100 ? '🌟 PERFECT SCORE!' : percentage >= 70 ? '💪 Great job!' : '📚 Keep practicing!'}

Join me on Quizzy!
#Quizzy #Learning #Quiz
''';

      await Share.share(message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }
}
