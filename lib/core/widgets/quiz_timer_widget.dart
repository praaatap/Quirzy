import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';

/// 5️⃣ TIMER ANIMATIONS (Quiz Pressure ⏱️)
/// Countdown circle with color changes: Green → Yellow → Red

class QuizCountdownTimer extends StatelessWidget {
  final int duration;
  final CountDownController? controller;
  final VoidCallback? onComplete;
  final bool isActive;

  const QuizCountdownTimer({
    super.key,
    required this.duration,
    this.controller,
    this.onComplete,
    this.isActive = true,
  });

  Color _getTimerColor(int remaining, int total) {
    final percentage = remaining / total;
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.25) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CircularCountDownTimer(
      duration: duration,
      initialDuration: 0,
      controller: controller ?? CountDownController(),
      width: 80,
      height: 80,
      ringColor: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
      ringGradient: null,
      fillColor: Colors.transparent,
      fillGradient: LinearGradient(
        colors: [
          _getTimerColor(duration ~/ 2, duration),
          _getTimerColor(duration ~/ 3, duration),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
      backgroundGradient: null,
      strokeWidth: 6.0,
      strokeCap: StrokeCap.round,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      textFormat: CountdownTextFormat.S,
      isReverse: true,
      isReverseAnimation: true,
      isTimerTextShown: true,
      autoStart: isActive,
      onComplete: onComplete,
      onChange: (String timeStamp) {
        // Optional: Add haptic feedback at certain intervals
        // Example: HapticFeedback.lightImpact() when time is running out
      },
    );
  }
}

// ==========================================
// ANIMATED CIRCULAR TIMER (Custom)
// ==========================================
class AnimatedCircularTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final bool isPaused;

  const AnimatedCircularTimer({
    super.key,
    required this.seconds,
    this.onComplete,
    this.isPaused = false,
  });

  @override
  State<AnimatedCircularTimer> createState() => _AnimatedCircularTimerState();
}

class _AnimatedCircularTimerState extends State<AnimatedCircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );

    _controller.addListener(() {
      final newSeconds = (widget.seconds * (1 - _controller.value)).round();
      if (newSeconds != _currentSeconds) {
        setState(() {
          _currentSeconds = newSeconds;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (!widget.isPaused) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor() {
    final percentage = _currentSeconds / widget.seconds;
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.25) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressColor = _getProgressColor();

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated circular progress
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(80, 80),
                painter: CircularTimerPainter(
                  progress: 1 - _controller.value,
                  progressColor: progressColor,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  strokeWidth: 6,
                ),
              );
            },
          ),
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_currentSeconds',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              Text(
                'sec',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER FOR CIRCULAR TIMER
// ==========================================
class CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor, progressColor.withOpacity(0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.14159 / 180), // Start from top
      360 * progress * (3.14159 / 180), // Sweep angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

// ==========================================
// COMPACT TIMER INDICATOR
// ==========================================
class CompactTimerIndicator extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isPaused;

  const CompactTimerIndicator({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    this.isPaused = false,
  });

  Color _getTimerColor() {
    final percentage = secondsRemaining / totalSeconds;
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.25) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timerColor = _getTimerColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaused ? Icons.pause_circle : Icons.timer,
            size: 18,
            color: timerColor,
          ),
          const SizedBox(width: 8),
          Text(
            isPaused ? 'PAUSED' : '${secondsRemaining}s',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }
}
