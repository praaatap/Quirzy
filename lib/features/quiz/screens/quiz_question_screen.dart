import 'dart:async';
import 'dart:math';
// import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/quiz/screens/quiz_complete_screen.dart';
// import 'package:quirzy/core/widgets/micro_animations.dart';
// import 'package:quirzy/core/widgets/quiz_timer_widget.dart';

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
  String? selectedOption;

  // Power-up States
  bool _hasUsed5050 = false;
  bool _hasUsedFreeze = false;
  bool _hasUsedSecondChance = false;

  bool _isSecondChanceActive = false;
  bool _isFrozen = false;
  final Set<String> _hiddenOptions = {};

  // Animation Controllers
  late AnimationController _progressController;

  late AnimationController _questionTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Progress Animation
    _progressController = AnimationController(
      vsync: this,
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
    _progressController.dispose();
    _questionTransitionController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _isFrozen = false; // Reset freeze on new question?
    // Usually freeze lasts for a specific time or one turn.
    // Let's reset freeze when changing question to avoid bugs.

    setState(() {
      _secondsRemaining = widget.timePerQuestion;
      _isTimerActive = true;
      _isAnswerSubmitted = false;
      _hiddenOptions.clear(); // Clear 50/50 hidden options
      _isSecondChanceActive =
          false; // Reset second chance active state (it's consumed or reset)
      // Wait, second chance should carry over if not consumed?
      // Simpler logic: It applies to the current question once activated.
      // Or usually it is a global "lifeline" you activate.
      // Let's say if you activate it, it stays active until you make a mistake.
      // But typically lifelines are "use now". We'll keep it simple:
      // It protects you for THIS question.
    });

    _progressController.duration = Duration(seconds: widget.timePerQuestion);
    _progressController.reverse(from: 1.0);

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isFrozen) return; // Logic for Freeze

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
        });
        _handleNextQuestion(autoAdvance: true);
      }
    });
  }

  // ==========================================
  // POWER-UP LOGIC
  // ==========================================

  void _use5050() {
    if (_hasUsed5050) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _hasUsed5050 = true;
    });

    final currentQuestion = widget.questions[currentQuestionIndex];
    final options = (currentQuestion['options'] as List<dynamic>)
        .cast<String>();
    final correctAnswerIndex = currentQuestion['correctAnswer'] as int;
    final correctAnswer = options[correctAnswerIndex];

    final incorrectOptions = options.where((o) => o != correctAnswer).toList();
    incorrectOptions.shuffle();

    // Hide 2 incorrect options (or 1 if there are only 2 options total)
    int toHideCount = min(2, incorrectOptions.length);

    setState(() {
      _hiddenOptions.addAll(incorrectOptions.take(toHideCount));
    });

    _showPowerUpSnackBar(
      'AI Cut applied! 2 wrong answers removed.',
      Colors.purpleAccent,
    );
  }

  void _useFreeze() {
    if (_hasUsedFreeze) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _hasUsedFreeze = true;
      _isFrozen = true;
    });

    _progressController.stop(); // Stop visual progress

    _showPowerUpSnackBar('Time Frozen! Take your time.', Colors.cyanAccent);
  }

  void _useSecondChance() {
    if (_hasUsedSecondChance) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _hasUsedSecondChance = true;
      _isSecondChanceActive = true;
    });

    _showPowerUpSnackBar(
      'Shield Active! Protected from one mistake.',
      Colors.greenAccent,
    );
  }

  void _showPowerUpSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  void _handleNextQuestion({bool autoAdvance = false}) {
    if (_isAnswerSubmitted) return;

    // Second Chance Logic
    if (selectedOption != null && !autoAdvance) {
      final currentQuestion = widget.questions[currentQuestionIndex];
      final options = (currentQuestion['options'] as List<dynamic>)
          .cast<String>();
      final selectedIndex = options.indexOf(selectedOption!);
      final isCorrect = selectedIndex == currentQuestion['correctAnswer'];

      if (!isCorrect && _isSecondChanceActive) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isSecondChanceActive = false; // Consumed
          selectedOption = null; // Reset selection
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shield Saved You! Try again.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return; // EXIT FUNCTION - Give second chance
      }
    }

    setState(() {
      _isAnswerSubmitted = true;
      _isFrozen = false; // Unfreeze if frozen
    });

    // Haptic Feedback on submit
    HapticFeedback.mediumImpact();

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
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            selectedOption = null;
            currentQuestionIndex++;
            _isAnswerSubmitted = false;
          });
          _questionTransitionController.reset();
          _questionTransitionController.forward();
          _startQuestionTimer();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
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
          backgroundColor: Colors.redAccent,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Quit Quiz?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Your progress needs to be saved. Are you sure you want to exit?',
          style: GoogleFonts.plusJakartaSans(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) _startQuestionTimer();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Quit',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
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
    final primaryColor = theme.colorScheme.primary;

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              _questionTimer?.cancel();
              _showQuitDialog(theme);
            },
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isFrozen ? Icons.ac_unit : Icons.timer_rounded,
                  size: 16,
                  color: _isFrozen
                      ? Colors.cyanAccent
                      : (_secondsRemaining < 10 ? Colors.red : primaryColor),
                ),
                const SizedBox(width: 6),
                Text(
                  _isFrozen ? 'FROZEN' : '${_secondsRemaining}s',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isFrozen
                        ? Colors.cyanAccent
                        : (_secondsRemaining < 10 ? Colors.red : primaryColor),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${currentQuestionIndex + 1} / ${widget.questions.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // 1. Premium Background
            _buildBackground(theme, isDark),

            // 2. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.transparent,
                          color: primaryColor.withOpacity(0.3),
                          minHeight: 2,
                        );
                      },
                    ),
                  ),

                  // POWER-UPS BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPowerUpButton(
                          icon: Icons.content_cut_rounded,
                          label: '50/50',
                          color: Colors.purpleAccent,
                          isUsed: _hasUsed5050,
                          onTap: _use5050,
                          theme: theme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildPowerUpButton(
                          icon: Icons.ac_unit_rounded,
                          label: 'Freeze',
                          color: Colors.cyanAccent,
                          isUsed: _hasUsedFreeze,
                          onTap: _useFreeze,
                          theme: theme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildPowerUpButton(
                          icon: Icons.shield_rounded,
                          label: 'Shield',
                          color: Colors.greenAccent,
                          isUsed: _hasUsedSecondChance,
                          onTap: _useSecondChance,
                          theme: theme,
                          isDark: isDark,
                          isActive: _isSecondChanceActive,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Question Card
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E24).withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(
                                        isDark ? 0.15 : 0.08,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.difficulty != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(
                                            widget.difficulty!,
                                            isDark,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          widget.difficulty!.toUpperCase(),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getDifficultyColor(
                                              widget.difficulty!,
                                              isDark,
                                            ),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Text(
                                      questionText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Options
                          ...List.generate(options.length, (index) {
                            final option = options[index];
                            final isSelected = selectedOption == option;
                            final isHidden = _hiddenOptions.contains(option);

                            if (isHidden)
                              return const SizedBox.shrink(); // Hide option

                            // Staggered Animation for options
                            final animation = CurvedAnimation(
                              parent: _questionTransitionController,
                              curve: Interval(
                                0.5 + (index * 0.1),
                                1.0,
                                curve: Curves.easeOutBack,
                              ),
                            );

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: OptionCard(
                                    option: option,
                                    label: String.fromCharCode(65 + index),
                                    isSelected: isSelected,
                                    onTap: !_isTimerActive || _isAnswerSubmitted
                                        ? null
                                        : () {
                                            HapticFeedback.selectionClick();
                                            setState(
                                              () => selectedOption = option,
                                            );
                                          },
                                    theme: theme,
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Next Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: selectedOption != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: selectedOption != null && !_isAnswerSubmitted
                          ? () => _handleNextQuestion()
                          : null,
                      child: Text(
                        currentQuestionIndex < widget.questions.length - 1
                            ? 'Next Question'
                            : 'Finish Quiz',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isUsed,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: isUsed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUsed
              ? (isActive
                    ? color
                    : (isDark
                          ? Colors.white10
                          : Colors.black12)) // Active shield stays colored
              : (isDark ? const Color(0xFF27272A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUsed
                ? (isActive ? color : Colors.transparent)
                : (isActive ? color : color.withOpacity(0.5)),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive || (!isUsed)
              ? [
                  BoxShadow(
                    color: color.withOpacity(isActive ? 0.4 : 0.2),
                    blurRadius: isActive ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isUsed ? (isActive ? Colors.white : Colors.grey) : color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, bool isDark) {
    return Container(color: theme.scaffoldBackgroundColor);
  }

  Color _getDifficultyColor(String difficulty, bool isDark) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return isDark ? Colors.greenAccent : Colors.green;
      case 'hard':
        return isDark ? Colors.redAccent : Colors.red;
      case 'medium':
      default:
        return Colors.orange;
    }
  }
}

class OptionCard extends StatelessWidget {
  final String option;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final ThemeData theme;
  final bool isDark;
  final Color primaryColor;

  const OptionCard({
    super.key,
    required this.option,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? primaryColor
        : (isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05));

    final bgColor = isSelected
        ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
        : (isDark ? const Color(0xFF1E1E24) : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}
