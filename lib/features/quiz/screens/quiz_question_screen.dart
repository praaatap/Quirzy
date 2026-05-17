import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'quiz_complete_screen.dart';
import '../../../shared/theme/quiz_theme.dart';
import '../widgets/timer_widget.dart';
import '../widgets/power_up_button.dart';
import '../widgets/option_card.dart';
import '../widgets/quiz_progress_bar.dart';

/// A screen that displays quiz questions with timer, power-ups, and interactive options.
///
/// Features:
/// - Animated question transitions
/// - Timer with freeze power-up support
/// - Power-ups: 50/50, Freeze, Shield
/// - Streak counter for consecutive correct answers
/// - Confetti celebration for correct answers
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
  // ══════════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ══════════════════════════════════════════════════════════════════════════

  // Quiz Progress
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  String? _selectedOption;

  // Answer Tracking
  late List<bool> _userAnswers;
  late List<int> _userSelectedAnswers;

  // Timer State
  Timer? _questionTimer;
  int _secondsRemaining = 30;
  bool _isTimerActive = true;
  bool _isAnswerSubmitted = false;

  // Power-up Usage Flags
  bool _hasUsed5050 = false;
  bool _hasUsedFreeze = false;
  bool _hasUsedSecondChance = false;

  // Power-up Active States
  bool _isSecondChanceActive = false;
  bool _isFrozen = false;
  final Set<String> _hiddenOptions = {};

  // ══════════════════════════════════════════════════════════════════════════
  // ANIMATION CONTROLLERS
  // ══════════════════════════════════════════════════════════════════════════

  late AnimationController _questionTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS FOR CURRENT QUESTION DATA
  // ══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> get _currentQuestion =>
      widget.questions[_currentQuestionIndex];

  List<String> get _currentOptions =>
      (_currentQuestion['options'] as List).map((e) => e.toString()).toList();

  int get _correctAnswerIndex => _currentQuestion['correctAnswer'] as int;

  String get _correctOption => _currentOptions[_correctAnswerIndex];

  String get _questionText => _currentQuestion['questionText'] as String;

  String? get _explanation => _currentQuestion['explanation'] as String?;

  bool get _isLastQuestion =>
      _currentQuestionIndex >= widget.questions.length - 1;

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHODS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    if (widget.questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    _initializeState();
    _initializeAnimations();
    _startAfterBuild();
  }

  void _initializeState() {
    _userAnswers = List.filled(widget.questions.length, false);
    _userSelectedAnswers = List.filled(widget.questions.length, -1);
    _currentStreak = 0;
  }

  void _initializeAnimations() {
    // Confetti Controller
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
  }

  void _startAfterBuild() {
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

  // ══════════════════════════════════════════════════════════════════════════
  // TIMER LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _isFrozen = false;

    setState(() {
      _secondsRemaining = widget.timePerQuestion;
      _isTimerActive = true;
      _isAnswerSubmitted = false;
      _hiddenOptions.clear();
      _isSecondChanceActive = false;
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  void _onTimerTick(Timer timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }

    if (_isFrozen) return;

    if (_secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
    } else {
      timer.cancel();
      _handleAnswerSubmission(isTimeOut: true);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // POWER-UP LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  void _use5050() {
    if (_hasUsed5050 || _isAnswerSubmitted || _hiddenOptions.isNotEmpty) return;

    setState(() {
      _hasUsed5050 = true;

      // Get wrong options and hide 2 of them
      final wrongOptions =
          _currentOptions.where((o) => o != _correctOption).toList()..shuffle();

      _hiddenOptions.addAll(wrongOptions.take(2));
    });
  }

  void _useFreeze() {
    if (_hasUsedFreeze || _isAnswerSubmitted || _isFrozen) return;

    setState(() {
      _hasUsedFreeze = true;
      _isFrozen = true;
    });

    // Auto-unfreeze after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isFrozen) {
        setState(() => _isFrozen = false);
      }
    });
  }

  void _useSecondChance() {
    if (_hasUsedSecondChance || _isAnswerSubmitted || _isSecondChanceActive) {
      return;
    }

    setState(() {
      _hasUsedSecondChance = true;
      _isSecondChanceActive = true;
    });

    _showSnackBar(
      'Shield Activated! You get a second try if you miss.',
      QuizTheme.colorShield,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ANSWER HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  void _handleOptionSelected(String option) {
    if (!_isTimerActive || _isAnswerSubmitted || _selectedOption == option) {
      return;
    }

    final isCorrect = option == _correctOption;

    // Handle Second Chance power-up
    if (!isCorrect && _isSecondChanceActive) {
      _consumeSecondChance();
      return;
    }

    setState(() {
      _selectedOption = option;
      _isAnswerSubmitted = true;
    });

    _handleAnswerSubmission();
  }

  void _consumeSecondChance() {
    HapticFeedback.heavyImpact();
    setState(() => _isSecondChanceActive = false);
    _showSnackBar('Shield broke! Try again!', Colors.orange);
  }

  void _handleAnswerSubmission({bool isTimeOut = false}) {
    _questionTimer?.cancel();
    _isTimerActive = false;

    final isCorrect = !isTimeOut && _selectedOption == _correctOption;

    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }

    _saveUserAnswer();
    _scheduleNextQuestion();
  }

  void _handleCorrectAnswer() {
    HapticFeedback.lightImpact();
    _confettiController.play();
    setState(() {
      _correctAnswers++;
      _currentStreak++;
      _userAnswers[_currentQuestionIndex] = true;
    });
  }

  void _handleWrongAnswer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStreak = 0;
      _userAnswers[_currentQuestionIndex] = false;
    });
  }

  void _saveUserAnswer() {
    _userSelectedAnswers[_currentQuestionIndex] = _selectedOption != null
        ? _currentOptions.indexOf(_selectedOption!)
        : -1;
  }

  void _scheduleNextQuestion() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _advanceToNextQuestion();
    });
  }

  void _advanceToNextQuestion() {
    if (!_isLastQuestion) {
      setState(() {
        _selectedOption = null;
        _currentQuestionIndex++;
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
              score: _correctAnswers,
              totalQuestions: widget.questions.length,
              userAnswers: _userAnswers,
              userSelectedAnswers: _userSelectedAnswers,
              questions: widget.questions,
              difficulty: widget.difficulty,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
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
        content: const Text('You will lose your progress.'),
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

  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'easy' => const Color(0xFF10B981),
      'medium' => const Color(0xFFF59E0B),
      'hard' => const Color(0xFFEF4444),
      _ => QuizTheme.primary,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD METHOD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          _buildBackgroundDecoration(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(theme, isDark),
                const SizedBox(height: 10),
                _buildTimer(),
                _buildPowerUps(isDark),
                const SizedBox(height: 16),
                _buildQuestionArea(isDark),
              ],
            ),
          ),
          _buildConfettiOverlay(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBackgroundDecoration(bool isDark) {
    return Positioned(
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
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildCloseButton(theme, isDark),
          _buildProgressBar(isDark),
          if (widget.difficulty != null) _buildDifficultyBadge(),
          const SizedBox(width: 8),
          if (_currentStreak > 1) _buildStreakCounter(),
        ],
      ),
    );
  }

  Widget _buildCloseButton(ThemeData theme, bool isDark) {
    return IconButton(
      onPressed: () => _showQuitDialog(theme),
      icon: Icon(
        Icons.close_rounded,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: QuizProgressBar(
          currentIndex: _currentQuestionIndex,
          totalQuestions: widget.questions.length,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    final color = _getDifficultyColor(widget.difficulty!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        widget.difficulty!.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥'),
          const SizedBox(width: 4),
          Text(
            '$_currentStreak',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
  }

  Widget _buildTimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TimerWidget(
        secondsRemaining: _secondsRemaining,
        totalSeconds: widget.timePerQuestion,
        isFrozen: _isFrozen,
      ),
    );
  }

  Widget _buildPowerUps(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
    );
  }

  Widget _buildQuestionArea(bool isDark) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuestionCard(isDark),
            ..._buildOptionCards(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? QuizTheme.surfaceDark : QuizTheme.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              _buildQuestionNumber(),
              const SizedBox(height: 12),
              _buildQuestionText(isDark),
              if (_isAnswerSubmitted && _explanation != null)
                _buildExplanation(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionNumber() {
    return Text(
      'Question ${_currentQuestionIndex + 1}',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: QuizTheme.primary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildQuestionText(bool isDark) {
    return Text(
      _questionText,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: isDark ? Colors.white : const Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildExplanation(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: QuizTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuizTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: QuizTheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _explanation!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildOptionCards(bool isDark) {
    return List.generate(_currentOptions.length, (index) {
      final option = _currentOptions[index];

      // Hide options removed by 50/50 power-up
      if (_hiddenOptions.contains(option)) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOptionCard(option, index, isDark),
      );
    });
  }

  Widget _buildOptionCard(String option, int index, bool isDark) {
    final isSelected = _selectedOption == option;
    final label = String.fromCharCode(65 + index); // A, B, C, D...

    // Determine correct/wrong state for visual feedback
    bool? isCorrectState;
    if (_isAnswerSubmitted) {
      if (option == _correctOption) {
        isCorrectState = true;
      } else if (isSelected) {
        isCorrectState = false;
      }
    }

    final delay = index * 100;

    return OptionCard(
          option: option,
          label: label,
          isSelected: isSelected,
          isCorrect: isCorrectState,
          onTap: () => _handleOptionSelected(option),
          isDark: isDark,
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: delay.ms);
  }

  Widget _buildConfettiOverlay() {
    return Align(
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
    );
  }
}
