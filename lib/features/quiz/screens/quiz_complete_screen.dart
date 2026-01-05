import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';
import 'package:quirzy/core/services/app_review_service.dart';
import 'package:quirzy/core/services/game_effects_service.dart';

class QuizCompleteScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final List<bool> userAnswers;
  final List<int> userSelectedAnswers;
  final List<Map<String, dynamic>> questions;
  final String? difficulty;

  const QuizCompleteScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.userAnswers,
    required this.userSelectedAnswers,
    required this.questions,
    this.difficulty,
  });

  @override
  ConsumerState<QuizCompleteScreen> createState() => _QuizCompleteScreenState();
}

class _QuizCompleteScreenState extends ConsumerState<QuizCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _startAnimations();
    _saveResult();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    // Trigger in-app review after animations
    _requestReview();
  }

  Future<void> _requestReview() async {
    try {
      // Record quiz completion for review service
      final reviewService = AppReviewService();
      await reviewService.initialize();
      await reviewService.recordQuizCompleted();

      // Add game effect for completion
      GameEffectsService().successVibration();

      // Check if we should show review prompt
      // This is based on: 3+ quizzes, 3+ days usage, not prompted recently
      if (reviewService.shouldShowReviewPrompt()) {
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          await AppReviewService.showReviewDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Error with review service: $e');
    }
  }

  Future<void> _saveResult() async {
    setState(() => _isSaving = true);

    try {
      final quizService = ref.read(quizServiceProvider);
      await quizService.saveQuizResult(
        quizId: widget.quizId,
        quizTitle: widget.quizTitle,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        questions: widget.questions,
        userSelectedAnswers: widget.userSelectedAnswers,
      );
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saved = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        debugPrint('Failed to save quiz result: $e');
      }
    }
  }

  double get percentage => widget.totalQuestions > 0
      ? (widget.score / widget.totalQuestions) * 100
      : 0;

  String get performanceMessage {
    if (percentage >= 90) return 'Outstanding!';
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 70) return 'Great job!';
    if (percentage >= 60) return 'Good work!';
    if (percentage >= 50) return 'Keep practicing!';
    return 'Don\'t give up!';
  }

  Color get performanceColor {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData get performanceIcon {
    if (percentage >= 80) return Icons.emoji_events_rounded;
    if (percentage >= 60) return Icons.thumb_up_rounded;
    return Icons.refresh_rounded;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      performanceColor.withOpacity(isDark ? 0.2 : 0.25),
                      performanceColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(
                        isDark ? 0.1 : 0.15,
                      ),
                      theme.colorScheme.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Score circle
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            performanceColor,
                            performanceColor.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: performanceColor.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(performanceIcon, size: 40, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            '${percentage.round()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Performance message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          performanceMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.quizTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Stats row
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            icon: Icons.check_circle_rounded,
                            value: '${widget.score}',
                            label: 'Correct',
                            color: Colors.green,
                            theme: theme,
                          ),
                          _StatItem(
                            icon: Icons.cancel_rounded,
                            value: '${widget.totalQuestions - widget.score}',
                            label: 'Wrong',
                            color: Colors.red,
                            theme: theme,
                          ),
                          _StatItem(
                            icon: Icons.help_outline_rounded,
                            value: '${widget.totalQuestions}',
                            label: 'Total',
                            color: theme.colorScheme.primary,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save status
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _saved
                            ? Colors.green.withOpacity(0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSaving)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          else
                            Icon(
                              _saved
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 16,
                              color: _saved
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _isSaving
                                ? 'Saving...'
                                : _saved
                                ? 'Saved to history'
                                : 'Not saved',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _saved
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Action buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                icon: const Icon(Icons.home_rounded),
                                label: Text(
                                  'Back to Home',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              // Show review answers bottom sheet
                              _showAnswersReview(context);
                            },
                            child: Text(
                              'Review Answers',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswersReview(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Review Answers',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  final userAnswer = widget.userSelectedAnswers[index];
                  final correctAnswer = question['correctAnswer'] ?? 0;
                  final options = (question['options'] as List<dynamic>?) ?? [];
                  final isCorrect = userAnswer == correctAnswer;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCorrect ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCorrect
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question['questionText'] ?? 'No question',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (userAnswer >= 0 && userAnswer < options.length)
                          Text(
                            'Your answer: ${options[userAnswer]}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        if (!isCorrect &&
                            correctAnswer >= 0 &&
                            correctAnswer < options.length)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Correct: ${options[correctAnswer]}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
