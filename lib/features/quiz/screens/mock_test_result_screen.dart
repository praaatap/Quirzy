import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_test_service.dart';
import '../services/rank_predictor_service.dart';
import 'mock_test_setup_screen.dart';
import 'rank_predictor_screen.dart';

class MockTestResultScreen extends StatelessWidget {
  final MockTestData mockTest;
  final List<int?> answers;
  final int score;
  final int timeTakenSeconds;

  const MockTestResultScreen({
    super.key,
    required this.mockTest,
    required this.answers,
    required this.score,
    required this.timeTakenSeconds,
  });

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }

  String _getGrade(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    return 'D';
  }

  Color _getGradeColor(double pct) {
    if (pct >= 80) return Colors.green;
    if (pct >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? Colors.white60 : const Color(0xFF64748B);

    final pct = mockTest.totalQuestions > 0 ? (score / mockTest.totalQuestions * 100) : 0.0;
    final grade = _getGrade(pct);
    final gradeColor = _getGradeColor(pct);
    final answered = answers.where((a) => a != null).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Test Results', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textMain)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Score hero card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradeColor.withOpacity(0.15), const Color(0xFF5B13EC).withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: gradeColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: pct / 100,
                                    strokeWidth: 8,
                                    backgroundColor: gradeColor.withOpacity(0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(grade, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: gradeColor)),
                                    Text('${pct.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mockTest.title,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain),
                                ),
                                const SizedBox(height: 8),
                                _resultRow('Score', '$score / ${mockTest.totalQuestions}', textSub, textMain),
                                _resultRow('Answered', '$answered / ${mockTest.totalQuestions}', textSub, textMain),
                                _resultRow('Time', _formatTime(timeTakenSeconds), textSub, textMain),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Section-wise breakdown
                  Text('Section Breakdown', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                  const SizedBox(height: 12),
                  ...mockTest.sections.map((section) {
                    final sectionPct = section.questionCount > 0 ? (section.correct / section.questionCount * 100) : 0.0;
                    final sectionColor = _getGradeColor(sectionPct);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(section.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textMain)),
                              Text(
                                '${section.correct}/${section.questionCount} (${sectionPct.toStringAsFixed(0)}%)',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: sectionColor, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: sectionPct / 100,
                              minHeight: 8,
                              backgroundColor: sectionColor.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(sectionColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _chip('Attempted: ${section.attempted}', Colors.blue, isDark),
                              const SizedBox(width: 8),
                              _chip('Skipped: ${section.questionCount - section.attempted}', Colors.grey, isDark),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: (mockTest.sections.indexOf(section) * 80).ms).fadeIn().slideX(begin: 0.1, end: 0);
                  }),
                  const SizedBox(height: 24),

                  // Answer Review Summary
                  Text('Answer Overview', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _scoreChip('Correct', score, Colors.green, isDark, textMain),
                            _scoreChip('Wrong', answered - score, Colors.red, isDark, textMain),
                            _scoreChip('Skipped', mockTest.totalQuestions - answered, Colors.grey, isDark, textMain),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rank Predictor CTA
                  _RankPredictorBanner(
                    mockTest: mockTest,
                    score: score,
                    surfaceColor: surfaceColor,
                    textMain: textMain,
                    textSub: textSub,
                    isDark: isDark,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              color: surfaceColor,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MockTestSetupScreen()),
                        (route) => route.isFirst,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5B13EC)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Retake', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF5B13EC))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B13EC),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Home', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: labelColor)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _scoreChip(String label, int count, Color color, bool isDark, Color textMain) {
    return Column(
      children: [
        Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ── Rank Predictor Banner ──────────────────────────────────────────────────

class _RankPredictorBanner extends StatelessWidget {
  final MockTestData mockTest;
  final int score;
  final Color surfaceColor;
  final Color textMain;
  final Color textSub;
  final bool isDark;

  const _RankPredictorBanner({
    required this.mockTest,
    required this.score,
    required this.surfaceColor,
    required this.textMain,
    required this.textSub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = mockTest.totalQuestions > 0
        ? score / mockTest.totalQuestions * 100
        : 0.0;
    final prediction = RankPredictorService.predict(
      examType: mockTest.examType,
      scorePercent: pct,
      totalQuestions: mockTest.totalQuestions,
    );
    final gradeColor = prediction.percentileLow >= 80
        ? Colors.green
        : prediction.percentileLow >= 60
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RankPredictorScreen(prediction: prediction),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF5B13EC).withOpacity(0.12),
              gradeColor.withOpacity(0.08),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF5B13EC).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5B13EC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.leaderboard_rounded,
                  color: Color(0xFF5B13EC), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Predicted Rank',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${_fmt(prediction.estimatedRankLow)} – #${_fmt(prediction.estimatedRankHigh)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                  Text(
                    '${prediction.percentileLow}–${prediction.percentileHigh} percentile · ${prediction.category}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: gradeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF5B13EC)),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
