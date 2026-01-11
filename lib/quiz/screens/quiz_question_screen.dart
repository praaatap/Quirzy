import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'quiz_complete_screen.dart';
import '../../shared/theme/quiz_theme.dart';
import '../widgets/timer_widget.dart';
import '../widgets/power_up_button.dart';
import '../widgets/option_card.dart';
import '../widgets/quiz_progress_bar.dart';

class QuizQuestionScreen extends ConsumerStatefulWidget {
  final String quizTitle;
  final String quizId;
  final List<Map<String, dynamic>> questions;
  final String? difficulty;
  final int timePerQuestion;

  const QuizQuestionScreen({
    super.key,
    required this.quizTitle,
    required this.quizId,
    required this.questions,
    this.difficulty,
    this.timePerQuestion = 30,
  });

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int currentStreak = 0;
  String? selectedOption;

  // Power-up States
  bool _hasUsed5050 = false;
  bool _hasUsedFreeze = false;
  bool _hasUsedSecondChance = false;

  bool _isSecondChanceActive = false;
  bool _isFrozen = false;
  final Set<String> _hiddenOptions = {};

  // Animation Controllers
  late AnimationController _questionTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;

  late List<bool> userAnswers;
  late List<int> userSelectedAnswers;

  Timer? _questionTimer;
  int _secondsRemaining = 30;
  bool _isTimerActive = true;
  bool _isAnswerSubmitted = false;

  @override
  void initState() {
    super.initState();

    if (widget.questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    userAnswers = List.filled(widget.questions.length, false);
    userSelectedAnswers = List.filled(widget.questions.length, -1);
    currentStreak = 0;

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    // Question Transition Animation
    _questionTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _questionTransitionController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _questionTransitionController,
            curve: Curves.easeOutCubic,
          ),
        );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _questionTransitionController.forward();
        _startQuestionTimer();
      }
    });
  }

  @override
  void dispose() {
    _questionTransitionController.dispose();
    _confettiController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _isFrozen = false;

    setState(() {
      _secondsRemaining = widget.timePerQuestion;
      _isTimerActive = true;
      _isAnswerSubmitted = false;
      _hiddenOptions.clear();
      // Second chance resets per question? Or once per quiz?
      // Usually lifelines are once per quiz.
      // Assuming once per quiz, so we don't reset _isSecondChanceActive here unless we want it to be per question.
      // But _isSecondChanceActive protects the CURRENT question.
      // So if it was active and used, it's gone. If active and NOT used (correct answer), does it carry over?
      // Let's say it consumes on activation for simplicity or protects until next mistake.
      // For now: It protects the current question only. If you don't use it, you lose it? No that's bad.
      // Let's reset active state, but keep _hasUsed flags.
      // If user activates it, it sets _isSecondChanceActive = true for this question.
      _isSecondChanceActive = false;
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isFrozen) return;

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _handleAnswerSubmission(isTimeOut: true);
      }
    });
  }

  // --- Power-Up Logic ---

  void _use5050() {
    if (_hasUsed5050 || _isAnswerSubmitted || _hiddenOptions.isNotEmpty) return;

    setState(() {
      _hasUsed5050 = true;

      final currentQ = widget.questions[currentQuestionIndex];
      // Safely handle options as List<String>
      final options = (currentQ['options'] as List)
          .map((e) => e.toString())
          .toList();
      final correctIndex = currentQ['correctAnswer'] as int;
      final correctOption = options[correctIndex];

      final wrongOptions = options.where((o) => o != correctOption).toList();
      wrongOptions.shuffle();

      // Hide 2 wrong options
      _hiddenOptions.addAll(wrongOptions.take(2));
    });
  }

  void _useFreeze() {
    if (_hasUsedFreeze || _isAnswerSubmitted || _isFrozen) return;

    setState(() {
      _hasUsedFreeze = true;
      _isFrozen = true;
    });

    // Unfreeze after 15 seconds automatically
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isFrozen) {
        setState(() => _isFrozen = false);
      }
    });
  }

  void _useSecondChance() {
    if (_hasUsedSecondChance || _isAnswerSubmitted || _isSecondChanceActive)
      return;

    setState(() {
      _hasUsedSecondChance = true;
      _isSecondChanceActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shield Activated! You get a second try if you miss.'),
        backgroundColor: QuizTheme.colorShield,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // --- Answer Logic ---

  void _handleOptionSelected(String option) {
    if (!_isTimerActive || _isAnswerSubmitted || selectedOption == option)
      return;

    // Check if second chance is active and this is the FIRST WRONG attempt
    // If we want allow "try again", we need to know if it's correct immediately?
    // Current flow: Select -> Submit (or Auto-Submit?).
    // Usually quiz apps select -> confirm OR select is final.
    // Let's assume Select IS Final.

    final currentQ = widget.questions[currentQuestionIndex];
    final options = (currentQ['options'] as List)
        .map((e) => e.toString())
        .toList();
    final correctIndex = currentQ['correctAnswer'] as int;
    final correctOption = options[correctIndex];

    bool isCorrect = option == correctOption;

    if (!isCorrect && _isSecondChanceActive) {
      // Second Chance Triggered
      HapticFeedback.heavyImpact();
      setState(() {
        _isSecondChanceActive = false; // Consumed
        // Visually disable this wrong option
        // Maybe just shake or show red temporarily?
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shield broke! Try again!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
      return; // Don't submit yet
    }

    setState(() {
      selectedOption = option;
      _isAnswerSubmitted = true;
    });

    _handleAnswerSubmission();
  }

  void _handleAnswerSubmission({bool isTimeOut = false}) {
    _questionTimer?.cancel();
    _isTimerActive = false;

    final currentQ = widget.questions[currentQuestionIndex];
    final options = (currentQ['options'] as List)
        .map((e) => e.toString())
        .toList();
    final correctIndex = currentQ['correctAnswer'] as int;
    final correctOption = options[correctIndex];

    bool isCorrect = !isTimeOut && selectedOption == correctOption;

    if (isCorrect) {
      HapticFeedback.lightImpact(); // Use light impact for success
      _confettiController.play();
      setState(() {
        correctAnswers++;
        currentStreak++;
        userAnswers[currentQuestionIndex] = true;
      });
    } else {
      HapticFeedback.mediumImpact(); // Heavier for wrong
      setState(() {
        currentStreak = 0;
        userAnswers[currentQuestionIndex] = false;
      });
    }

    // Save selected answer index
    if (selectedOption != null) {
      userSelectedAnswers[currentQuestionIndex] = options.indexOf(
        selectedOption!,
      );
    } else {
      userSelectedAnswers[currentQuestionIndex] = -1;
    }

    // Delay before next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _advanceToNextQuestion();
      }
    });
  }

  void _advanceToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        selectedOption = null;
        currentQuestionIndex++;
        _isAnswerSubmitted = false;
      });
      _questionTransitionController.reset();
      _questionTransitionController.forward();
      _startQuestionTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showQuitDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Quit Quiz?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: const Text('You will lose your progress properly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final question = widget.questions[currentQuestionIndex];
    final rawOptions = question['options'] as List;
    final options = rawOptions.map((e) => e.toString()).toList();
    final questionText = question['questionText'] as String;

    // For feedback
    final correctIndex = question['correctAnswer'] as int;
    final correctOption = options[correctIndex];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuizTheme.primary.withOpacity(isDark ? 0.1 : 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- Header Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      IconButton(
                        onPressed: () => _showQuitDialog(theme),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),

                      // Progress Bar
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: QuizProgressBar(
                            currentIndex: currentQuestionIndex,
                            totalQuestions: widget.questions.length,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // Streak Counter
                      if (currentStreak > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥'),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- Timer ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TimerWidget(
                    secondsRemaining: _secondsRemaining,
                    totalSeconds: widget.timePerQuestion,
                    isFrozen: _isFrozen,
                  ),
                ),

                // --- Power Ups ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PowerUpButton(
                        icon: Icons.content_cut_rounded,
                        label: '50/50',
                        color: QuizTheme.color5050,
                        isUsed: _hasUsed5050,
                        onTap: _use5050,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 24),
                      PowerUpButton(
                        icon: Icons.ac_unit_rounded,
                        label: 'Freeze',
                        color: QuizTheme.colorFreeze,
                        isUsed: _hasUsedFreeze,
                        onTap: _useFreeze,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 24),
                      PowerUpButton(
                        icon: Icons.shield_rounded,
                        label: 'Shield',
                        color: QuizTheme.colorShield,
                        isUsed: _hasUsedSecondChance,
                        isActive: _isSecondChanceActive,
                        onTap: _useSecondChance,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Question Area ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? QuizTheme.surfaceDark
                                    : QuizTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Question ${currentQuestionIndex + 1}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: QuizTheme.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    questionText,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF2D3436),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Options List
                        ...List.generate(options.length, (index) {
                          final option = options[index];
                          final isHidden = _hiddenOptions.contains(option);

                          if (isHidden) return const SizedBox.shrink();

                          // Determine state for this card
                          bool isSelected = selectedOption == option;
                          bool? isCorrectState; // null means don't show yet

                          if (_isAnswerSubmitted) {
                            if (option == correctOption) {
                              isCorrectState = true; // Show this is correct
                            } else if (isSelected) {
                              // If this was selected but not correct (implied by above)
                              isCorrectState = false;
                            }
                          }

                          // Stagger animation
                          final delay = index * 100;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child:
                                OptionCard(
                                      option: option,
                                      label: String.fromCharCode(65 + index),
                                      isSelected: isSelected,
                                      isCorrect: isCorrectState,
                                      onTap: () =>
                                          _handleOptionSelected(option),
                                      isDark: isDark,
                                    )
                                    .animate()
                                    .fadeIn(delay: delay.ms, duration: 400.ms)
                                    .slideX(
                                      begin: 0.1,
                                      end: 0,
                                      delay: delay.ms,
                                    ),
                          );
                        }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
