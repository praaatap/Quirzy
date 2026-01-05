import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/core/services/daily_streak_service.dart';

class XPCalendarWidget extends StatefulWidget {
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
  State<XPCalendarWidget> createState() => _XPCalendarWidgetState();
}

class _XPCalendarWidgetState extends State<XPCalendarWidget> {
  final DailyStreakService _streakService = DailyStreakService();
  int _currentStreak = 0;
  int _totalXP = 0;
  Map<DateTime, int> _loginHeatmap = {};

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    await _streakService.initialize();
    if (!mounted) return;

    setState(() {
      _currentStreak = _streakService.getCurrentStreak();
      _totalXP = _streakService.getTotalXP();
      _loginHeatmap = _streakService.getLoginHeatmap(days: 70);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Merge activity data with login heatmap
    final combinedData = <DateTime, int>{...widget.activityData};
    for (final entry in _loginHeatmap.entries) {
      final existing = combinedData[entry.key] ?? 0;
      combinedData[entry.key] = existing + entry.value;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <DateTime>[];

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
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                    color: _currentStreak > 0
                        ? Colors.orange
                        : (widget.isDark ? Colors.grey : Colors.grey.shade400),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Daily Streak',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _currentStreak > 0
                      ? Colors.orange.withOpacity(0.15)
                      : (widget.isDark
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_currentStreak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _currentStreak > 0
                            ? Colors.orange
                            : (widget.isDark
                                  ? Colors.grey
                                  : Colors.grey.shade600),
                      ),
                    ),
                    Text(
                      ' days',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? const Color(0xFF52525B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF2D2D35)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // XP Badge
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor.withOpacity(0.2),
                      widget.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalXP XP Earned',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : widget.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Calendar Grid
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(days.length, (index) {
                  final date = days[index];
                  final intensity = combinedData[date] ?? 0;
                  return _buildDayBox(date, intensity, today);
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 70 Days',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.isDark ? Colors.grey : Colors.black45,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Less',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isDark ? Colors.grey : Colors.black45,
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
                          color: widget.isDark ? Colors.grey : Colors.black45,
                        ),
                      ),
                    ],
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
    Color color;
    if (count == 0) {
      color = widget.isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F5F9);
    } else if (count <= 2) {
      color = widget.primaryColor.withOpacity(0.3);
    } else if (count <= 4) {
      color = widget.primaryColor.withOpacity(0.6);
    } else {
      color = widget.primaryColor;
    }

    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Tooltip(
      message: '${_formatDate(date)}: $count activities',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(
                  color: widget.isDark ? Colors.white : Colors.black,
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
      color = widget.isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F5F9);
    } else if (count == 1) {
      color = widget.primaryColor.withOpacity(0.3);
    } else if (count == 3) {
      color = widget.primaryColor.withOpacity(0.6);
    } else {
      color = widget.primaryColor;
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
