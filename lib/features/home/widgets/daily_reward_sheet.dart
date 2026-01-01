import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final bgColor = isDark ? const Color(0xFF1E1730) : Colors.white;
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

              // Calendar Grid (Last 7 Days)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF251E38) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.asMap().entries.map((entry) {
                    final date = entry.value;
                    final index = entry.key; // 0 to 6 (6 is today)
                    final isToday = index == 6;
                    final isStreakDay = (6 - index) < widget.day;

                    final dayLetter = DateFormat('E').format(date)[0];

                    return Column(
                      children: [
                        Text(
                          dayLetter,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isStreakDay
                                ? textColor
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isStreakDay
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // Rounded Square instead of Circle for modern look
                                border: Border.all(
                                  color: isStreakDay
                                      ? primaryColor
                                      : (isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                  width: 1.5,
                                ),
                                boxShadow: isStreakDay && isToday
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isStreakDay
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : null,
                            )
                            .animate(target: isToday ? 1 : 0)
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    );
                  }).toList(),
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
