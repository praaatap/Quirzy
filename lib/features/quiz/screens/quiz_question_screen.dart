import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:quirzy/features/quiz/screens/quiz_complete_screen.dart';

class QuizQuestionScreen extends ConsumerStatefulWidget {
  final String quizTitle;
  final String quizId; // <--- 1. ADDED quizId variable
  final List<Map<String, dynamic>> questions;
  final String? difficulty;
  final int timePerQuestion;

  const QuizQuestionScreen({
    super.key,
    required this.quizTitle,
    required this.quizId, // <--- 2. ADDED to constructor
    required this.questions,
    this.difficulty,
    this.timePerQuestion = 30,
  });

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<bool> userAnswers;
  late List<int> userSelectedAnswers;

  Timer? _questionTimer;
  int _secondsRemaining = 30;
  bool _isTimerActive = true;
  bool _isAnswerSubmitted = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available')),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    userAnswers = List.filled(widget.questions.length, false);
    userSelectedAnswers = List.filled(widget.questions.length, -1);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        _startQuestionTimer();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _questionTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() {
      _secondsRemaining = widget.timePerQuestion;
      _isTimerActive = true;
      _isAnswerSubmitted = false;
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _handleNextQuestion(autoAdvance: true);
        });
      }
    });
  }

  void _resetAnimation() {
    _animationController.reset();
    _animationController.forward();
    // Scroll back to top when new question loads
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      _questionTimer?.cancel();
      setState(() {
        currentQuestionIndex--;
        selectedOption = userSelectedAnswers[currentQuestionIndex] != -1
            ? (widget.questions[currentQuestionIndex]['options']
                  as List<dynamic>)[userSelectedAnswers[currentQuestionIndex]]
            : null;
        _isAnswerSubmitted = false;
      });
      _resetAnimation();
      _startQuestionTimer();
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      _questionTimer?.cancel();
      setState(() {
        currentQuestionIndex++;
        selectedOption = userSelectedAnswers[currentQuestionIndex] != -1
            ? (widget.questions[currentQuestionIndex]['options']
                  as List<dynamic>)[userSelectedAnswers[currentQuestionIndex]]
            : null;
        _isAnswerSubmitted = false;
      });
      _resetAnimation();
      _startQuestionTimer();
    }
  }

  void _handleNextQuestion({bool autoAdvance = false}) {
    if (_isAnswerSubmitted) return;

    setState(() {
      _isAnswerSubmitted = true;
    });

    final currentQuestion = widget.questions[currentQuestionIndex];
    final options = (currentQuestion['options'] as List<dynamic>)
        .cast<String>();

    bool isCorrect = false;
    if (selectedOption != null) {
      final selectedIndex = options.indexOf(selectedOption!);
      userSelectedAnswers[currentQuestionIndex] = selectedIndex;
      isCorrect = selectedIndex == currentQuestion['correctAnswer'];

      if (isCorrect && !userAnswers[currentQuestionIndex]) {
        correctAnswers++;
        userAnswers[currentQuestionIndex] = true;
      }
    } else if (autoAdvance) {
      userSelectedAnswers[currentQuestionIndex] = -1;
    }

    _questionTimer?.cancel();

    if (currentQuestionIndex < widget.questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            selectedOption = null;
            currentQuestionIndex++;
            _isAnswerSubmitted = false;
          });
          _resetAnimation();
          _startQuestionTimer();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  QuizCompleteScreen(
                    quizId: widget.quizId,
                    quizTitle: widget.quizTitle,
                    score: correctAnswers,
                    totalQuestions: widget.questions.length,
                    userAnswers: userAnswers,
                    userSelectedAnswers: userSelectedAnswers,
                    questions: widget.questions,
                    difficulty: widget.difficulty,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      });
    }

    if (!autoAdvance && selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an answer!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showQuitDialog(ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quit Quiz?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Your progress will be lost. Are you sure?',
          style: GoogleFonts.poppins(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) _startQuestionTimer();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Quit',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.questions.isEmpty) return const SizedBox.shrink();

    final currentQuestion = widget.questions[currentQuestionIndex];
    final questionText = currentQuestion['questionText'] ?? 'No question text';
    final options =
        (currentQuestion['options'] as List<dynamic>?)?.cast<String>() ?? [];
    final progressValue = (currentQuestionIndex + 1) / widget.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _questionTimer?.cancel();
          _showQuitDialog(theme);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Custom Header (Non-scrollable)
              _buildHeader(theme, progressValue),

              // 2. Scrollable Content (Question + Options)
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Question Text
                        Text(
                          questionText,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Options
                        ...List.generate(options.length, (index) {
                          final option = options[index];
                          final isSelected = selectedOption == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OptionCard(
                              key: ValueKey('${currentQuestionIndex}_$option'),
                              option: option,
                              optionLabel: String.fromCharCode(65 + index),
                              isSelected: isSelected,
                              isEnabled: _isTimerActive && !_isAnswerSubmitted,
                              theme: theme,
                              onTap: (_isTimerActive && !_isAnswerSubmitted)
                                  ? () =>
                                        setState(() => selectedOption = option)
                                  : null,
                            ),
                          );
                        }),

                        // Extra bottom padding
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Pinned Bottom Navigation
              _buildBottomBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, double progressValue) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _questionTimer?.cancel();
                  _showQuitDialog(theme);
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(8),
                ),
              ),

              // Timer Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 10
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: _secondsRemaining <= 10
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_secondsRemaining s',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: _secondsRemaining <= 10
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Difficulty Badge or Spacer
              if (widget.difficulty != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      widget.difficulty!,
                      isDark,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDifficultyColor(
                        widget.difficulty!,
                        isDark,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.difficulty!.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(widget.difficulty!, isDark),
                    ),
                  ),
                )
              else
                const SizedBox(width: 48), // Balance spacing
            ],
          ),
          const SizedBox(height: 20),

          // Modern Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${currentQuestionIndex + 1}/${widget.questions.length}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: currentQuestionIndex > 0
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              onPressed: currentQuestionIndex > 0
                  ? _goToPreviousQuestion
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Next/Finish Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed:
                    (selectedOption != null &&
                        _isTimerActive &&
                        !_isAnswerSubmitted)
                    ? () => _handleNextQuestion()
                    : null,
                child: Text(
                  currentQuestionIndex < widget.questions.length - 1
                      ? "Next Question"
                      : "Finish Quiz",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, bool isDark) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'hard':
        return Colors.red;
      case 'medium':
      default:
        return Colors.orange;
    }
  }
}

class OptionCard extends StatelessWidget {
  final String option;
  final String optionLabel;
  final bool isSelected;
  final bool isEnabled;
  final ThemeData theme;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.optionLabel,
    required this.isSelected,
    required this.isEnabled,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.02),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
