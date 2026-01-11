import 'package:flutter/material.dart';
import '../../shared/theme/quiz_theme.dart';

class QuizProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final bool isDark;

  const QuizProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Determine how many dots to show based on screen width
    // Or just show a progress bar if too many questions
    final bool showDots = totalQuestions <= 15;

    if (!showDots) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (currentIndex + 1) / totalQuestions,
          backgroundColor: isDark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
          valueColor: const AlwaysStoppedAnimation(QuizTheme.primary),
          minHeight: 6,
        ),
      );
    }

    return Row(
      children: List.generate(totalQuestions, (index) {
        final bool isCompleted = index < currentIndex;
        final bool isCurrent = index == currentIndex;

        Color color;
        if (isCompleted) {
          color = QuizTheme.success;
        } else if (isCurrent) {
          color = QuizTheme.primary;
        } else {
          color = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);
        }

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalQuestions - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              gradient: isCurrent
                  ? QuizTheme.getGradient(QuizTheme.primaryGradient)
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
