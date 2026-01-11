import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/theme/quiz_theme.dart';

class TimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isFrozen;

  const TimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    this.isFrozen = false,
  });

  Color _getTimerColor() {
    if (isFrozen) return Colors.cyanAccent;
    final progress = secondsRemaining / totalSeconds;
    if (progress > 0.5) return QuizTheme.success;
    if (progress > 0.2) return QuizTheme.warning;
    return QuizTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / totalSeconds;
    final color = _getTimerColor();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            color: Colors.grey.withOpacity(0.1),
          ),
        ),

        // Animated Progress Circle
        SizedBox(
          width: 60,
          height: 60,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                color: color,
                strokeCap: StrokeCap.round,
              );
            },
          ),
        ),

        // Time Text
        if (isFrozen)
          const Icon(
            Icons.ac_unit_rounded,
            size: 24,
            color: Colors.cyanAccent,
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds)
        else
          Text(
                '$secondsRemaining',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
              .animate(
                key: ValueKey(secondsRemaining),
              ) // Animate on number change
              .scale(
                duration: 200.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.8, 0.8),
              ),
      ],
    );
  }
}
