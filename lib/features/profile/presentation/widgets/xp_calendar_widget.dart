import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XPCalendarWidget extends StatelessWidget {
  final Map<DateTime, int> activityData;
  final bool isDark;
  final Color primaryColor;

  const XPCalendarWidget({
    super.key,
    required this.activityData,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates for the last 60 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <DateTime>[];

    // We want to show roughly 8-10 weeks.
    // Let's show exactly 70 days (10 weeks) so it fits in a nice grid eventually
    for (int i = 69; i >= 0; i--) {
      days.add(today.subtract(Duration(days: i)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Log',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF64748B),
                ),
              ),
              Text(
                'Last 70 Days',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF52525B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2D2D35) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // We render 7 rows (days of week) and ~10 columns
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(days.length, (index) {
                  final date = days[index];
                  final intensity = activityData[date] ?? 0;

                  return _buildDayBox(date, intensity, today);
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _legendBox(0),
                  const SizedBox(width: 2),
                  _legendBox(1),
                  const SizedBox(width: 2),
                  _legendBox(3),
                  const SizedBox(width: 2),
                  _legendBox(5),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey : Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayBox(DateTime date, int count, DateTime today) {
    // Intensity: 0 (none), 1-2 (low), 3-4 (med), 5+ (high)
    Color color;
    if (count == 0) {
      color = isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F5F9);
    } else if (count <= 2) {
      color = primaryColor.withOpacity(0.3);
    } else if (count <= 4) {
      color = primaryColor.withOpacity(0.6);
    } else {
      color = primaryColor;
    }

    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Tooltip(
      message: '${_formatDate(date)}: $count quizzes',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 1.5,
                )
              : null,
        ),
      ),
    );
  }

  Widget _legendBox(int count) {
    Color color;
    if (count == 0) {
      color = isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F5F9);
    } else if (count == 1) {
      color = primaryColor.withOpacity(0.3);
    } else if (count == 3) {
      color = primaryColor.withOpacity(0.6);
    } else {
      color = primaryColor;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
