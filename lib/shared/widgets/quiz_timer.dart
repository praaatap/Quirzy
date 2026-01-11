import 'dart:async';
import 'package:flutter/material.dart';

/// Quiz Timer Widget
/// Countdown timer for quiz questions with visual feedback
class QuizTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onTimeUp;
  final ValueChanged<int>? onTick;
  final bool autoStart;
  final Color? activeColor;
  final Color? warningColor;
  final Color? dangerColor;

  const QuizTimer({
    super.key,
    required this.totalSeconds,
    this.onTimeUp,
    this.onTick,
    this.autoStart = true,
    this.activeColor,
    this.warningColor,
    this.dangerColor,
  });

  @override
  State<QuizTimer> createState() => QuizTimerState();
}

class QuizTimerState extends State<QuizTimer> with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        widget.onTick?.call(_remainingSeconds);
      } else {
        timer.cancel();
        _isRunning = false;
        widget.onTimeUp?.call();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.totalSeconds;
      _isRunning = false;
    });
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  Color _getColor() {
    final percentage = _remainingSeconds / widget.totalSeconds;
    if (percentage <= 0.2) {
      return widget.dangerColor ?? Colors.red;
    } else if (percentage <= 0.5) {
      return widget.warningColor ?? Colors.orange;
    }
    return widget.activeColor ?? Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = _remainingSeconds / widget.totalSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor(), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(_getColor()),
              backgroundColor: _getColor().withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          // Time text
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getColor(),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Timer configuration for different quiz difficulties
class QuizTimerConfig {
  static const int easySecondsPerQuestion = 45;
  static const int mediumSecondsPerQuestion = 30;
  static const int hardSecondsPerQuestion = 20;
  static const int expertSecondsPerQuestion = 15;

  static int getTimeForDifficulty(String difficulty, int questionCount) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easySecondsPerQuestion * questionCount;
      case 'hard':
        return hardSecondsPerQuestion * questionCount;
      case 'expert':
        return expertSecondsPerQuestion * questionCount;
      default:
        return mediumSecondsPerQuestion * questionCount;
    }
  }
}
