import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/rank_predictor_service.dart';

class RankPredictorScreen extends StatelessWidget {
  final RankPrediction prediction;

  const RankPredictorScreen({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? Colors.white60 : const Color(0xFF64748B);

    final pct = prediction.percentileLow;
    final gradeColor = pct >= 80
        ? Colors.green
        : pct >= 60
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Rank Predictor',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        iconTheme: IconThemeData(color: textMain),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: textMain),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero percentile card
          _heroCard(isDark, textMain, textSub, gradeColor, pct).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 20),

          // Rank range
          _sectionCard(
            isDark: isDark,
            surfaceColor: surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('Estimated Rank', '#${_fmt(prediction.estimatedRankLow)} – #${_fmt(prediction.estimatedRankHigh)}', gradeColor, textSub),
                Container(width: 1, height: 40, color: isDark ? Colors.white12 : Colors.black12),
                _statColumn('Percentile', '${prediction.percentileLow} – ${prediction.percentileHigh}', const Color(0xFF5B13EC), textSub),
                Container(width: 1, height: 40, color: isDark ? Colors.white12 : Colors.black12),
                _statColumn('Category', prediction.category, gradeColor, textSub),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),

          // Message
          _sectionCard(
            isDark: isDark,
            surfaceColor: surfaceColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B13EC).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insights_rounded, color: Color(0xFF5B13EC), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prediction.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: textMain,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(),
          const SizedBox(height: 16),

          // Cutoffs comparison
          if (prediction.cutoffs.isNotEmpty) ...[
            Text(
              'Cutoff Comparison',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            const SizedBox(height: 10),
            ...prediction.cutoffs.entries.toList().asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              final needed = entry.value;
              final cleared = pct >= needed;
              return _cutoffRow(
                entry.key,
                needed,
                cleared,
                isDark,
                surfaceColor,
                textMain,
                textSub,
              ).animate(delay: (200 + idx * 60).ms).fadeIn().slideX(begin: 0.08, end: 0);
            }),
            const SizedBox(height: 16),
          ],

          // Tips
          Text(
            'Improvement Tips',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 10),
          ...prediction.improvementTips.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B13EC).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5B13EC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textMain,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: (400 + e.key * 60).ms).fadeIn();
          }),

          const SizedBox(height: 8),
          Text(
            '* Rank estimates are based on historical score distributions and are indicative only.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textSub,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _heroCard(bool isDark, Color textMain, Color textSub, Color gradeColor, double pct) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradeColor.withOpacity(0.15),
            const Color(0xFF5B13EC).withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gradeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${prediction.examType} Mock Test',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: gradeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 10,
                  backgroundColor: gradeColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(gradeColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${pct.toStringAsFixed(1)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: gradeColor,
                    ),
                  ),
                  Text(
                    'Percentile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              prediction.category,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: gradeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required Color surfaceColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: child,
    );
  }

  Widget _statColumn(String label, String value, Color valueColor, Color labelColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: labelColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _cutoffRow(
    String name,
    double needed,
    bool cleared,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cleared
              ? Colors.green.withOpacity(0.3)
              : (isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            cleared ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: cleared ? Colors.green : (isDark ? Colors.white38 : Colors.black38),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textMain,
              ),
            ),
          ),
          Text(
            'Need ${needed.toStringAsFixed(0)}%ile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: cleared ? Colors.green : textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
