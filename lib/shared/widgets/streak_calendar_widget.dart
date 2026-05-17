import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/services/study_streak_service.dart';
import '../../config/theme_config.dart';

/// Streak Calendar Widget - GitHub-style contribution grid
class StreakCalendarWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const StreakCalendarWidget({super.key, this.onTap});

  @override
  State<StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends State<StreakCalendarWidget> {
  final _streakService = StudyStreakService();
  Map<String, dynamic> _streakData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final data = _streakService.getStreakCalendarData();
    if (mounted) {
      setState(() {
        _streakData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStreak = _streakData['currentStreak'] as int? ?? 0;
    final bestStreak = _streakData['bestStreak'] as int? ?? 0;
    final history = _streakData['history'] as Map<String, bool>? ?? {};

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  currentStreak > 0 ? Icons.local_fire_department : Icons.whatshot,
                  color: currentStreak > 0 ? Colors.orange : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentStreak Day Streak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                Text(
                  'Best: $bestStreak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar Grid (last 30 days)
            _buildCalendarGrid(history, isDark),
            const SizedBox(height: 8),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Less',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 4),
                _buildLegendItem(Colors.grey.withOpacity(0.2)),
                _buildLegendItem(ThemeConfig.primaryColor.withOpacity(0.3)),
                _buildLegendItem(ThemeConfig.primaryColor.withOpacity(0.6)),
                _buildLegendItem(ThemeConfig.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildCalendarGrid(Map<String, bool> history, bool isDark) {
    final now = DateTime.now();
    final days = <Widget>[];

    // Show last 30 days in a grid (7 columns)
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final studied = history[dateKey] ?? false;

      days.add(
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: studied
                ? ThemeConfig.primaryColor
                : isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: days,
    );
  }

  Widget _buildLegendItem(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
