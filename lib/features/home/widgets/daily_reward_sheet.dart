import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyRewardSheet extends StatefulWidget {
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
  State<DailyRewardSheet> createState() => _DailyRewardSheetState();
}

class _DailyRewardSheetState extends State<DailyRewardSheet>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto play confetti
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Returns list of 7 days ending today
  List<DateTime> _getLast7Days() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF120D1B);
    const primaryColor = Color(0xFF5B13EC); // Quirzy Purple
    const accentColor = Color(0xFFFFD700); // Gold

    final weekDays = _getLast7Days();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LeetCode-style Flame Icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        primaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.5, 0.8, 1.0],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 56,
                      color: primaryColor, // Purple flame
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Streak Count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.day}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day Streak',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'You are on fire! 🔥 Keep learning to maintain your streak.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Calendar Grid (Table Calendar)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262626) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                  ),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: DateTime.now(),
                  currentDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week,
                  headerVisible: false,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    weekendStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    weekendTextStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    todayDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    todayTextStyle: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    // Logic for highlighting previous streak days is a bit complex
                    // without a list of claimed dates.
                    // Assuming 'widget.day' is the streak, we highlight the last N days?
                    // TableCalendar doesn't support 'range' highlight for this well without
                    // a custom builder.
                    // Using markerBuilder or specific decoration logic.
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // Check if this day is part of the streak
                      // Streak = previous (widget.day - 1) days
                      final today = DateTime.now();
                      final difference = today.difference(day).inDays;
                      final isStreak =
                          difference > 0 && difference < widget.day;

                      if (isStreak) {
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primaryColor,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return null; // Use default
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // XP Reward Label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 24,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+${widget.xpReward} XP Earned',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Daily Bonus',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: accentColor.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().shimmer(duration: 2000.ms, color: Colors.white54),

              const SizedBox(height: 24),

              // Claim Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onClaim();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: Text(
                    'Continue Learning',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2, // down
          maxBlastForce: 20, // Increased force
          minBlastForce: 5,
          emissionFrequency: 0.05,
          numberOfParticles: 50, // More particles
          gravity: 0.2,
          colors: const [
            Color(0xFF5B13EC),
            Colors.cyan,
            Color(0xFFFFD700),
            Colors.pinkAccent,
          ],
        ),
      ],
    );
  }
}
