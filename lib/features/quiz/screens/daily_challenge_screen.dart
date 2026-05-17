import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/providers/user_stats_provider.dart';
import '../providers/daily_challenge_provider.dart';

/// ==================== DAILY CHALLENGE SCREEN ====================

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  // Challenge state
  List<DailyChallengeQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int> _userAnswers = [];
  bool _isAnswered = false;
  int? _selectedAnswer;
  bool _isLoading = true;
  bool _showResults = false;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _loadChallenge();
    _startCountdown();
  }

  Future<void> _loadChallenge() async {
    try {
      final questions = await ref.read(dailyChallengeQuestionsProvider.future);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeRemaining =
            DailyChallengeService.instance.getTimeUntilNextChallenge();
      });
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;
      _userAnswers.add(index);

      if (index == _questions[_currentQuestionIndex].correctIndex) {
        _score++;
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    });

    // Auto advance after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
        });
      } else {
        _completeChallenge();
      }
    });
  }

  Future<void> _completeChallenge() async {
    final service = DailyChallengeService.instance;

    // Save results
    final state = await service.saveChallengeResult(
      score: _score,
      totalQuestions: _questions.length,
      userAnswers: _userAnswers,
    );

    // Update streak
    await service.updateStreak();

    // Update user stats (XP)
    if (mounted) {
      await ref.read(userStatsProvider.notifier).addXP(state.xpEarned);
      await ref.read(userStatsProvider.notifier).incrementQuizCount();
    }

    // Show results
    if (mounted) {
      setState(() => _showResults = true);
      _confettiController.play();
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors
    const primary = Color(0xFF5B13EC);
    const secondary = Color(0xFF9333EA);
    const success = Color(0xFF10B981);
    const warning = Color(0xFFF59E0B);

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [primary.withOpacity(0.8), const Color(0xFF1E0A3C)]
                  : [primary, secondary.withOpacity(0.8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(
                              0.3 + _glowController.value * 0.3,
                            ),
                            blurRadius: 30 + _glowController.value * 20,
                            spreadRadius: _glowController.value * 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const Gap(24),
                Text(
                  'Preparing your challenge...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(16),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show completion/results screen
    if (_showResults) {
      final percentage = _questions.isNotEmpty
          ? ((_score / _questions.length) * 100).toDouble()
          : 0.0;
      final message = DailyChallengeService.instance.getMotivationalMessage(
        percentage,
        0, // Will be loaded async
      );

      return Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [primary.withOpacity(0.9), const Color(0xFF1E0A3C)]
                      : [primary, secondary.withOpacity(0.9)],
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF5B13EC),
                  Color(0xFF9333EA),
                  Color(0xFFFFD700),
                  Color(0xFF10B981),
                  Color(0xFFEC4899),
                  Color(0xFF3B82F6),
                ],
                numberOfParticles: 50,
                gravity: 0.15,
                emissionFrequency: 0.08,
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Gap(40),

                    // Trophy with glow
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                percentage >= 70
                                    ? const Color(0xFFFFD700)
                                    : primary,
                                percentage >= 70
                                    ? const Color(0xFFFFA500)
                                    : secondary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (percentage >= 70
                                        ? const Color(0xFFFFD700)
                                        : primary)
                                    .withOpacity(
                                  0.4 + _glowController.value * 0.2,
                                ),
                                blurRadius: 40 + _glowController.value * 20,
                                spreadRadius: _glowController.value * 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            percentage >= 70
                                ? Icons.emoji_events_rounded
                                : Icons.stars_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ).animate().scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        );
                      },
                    ),

                    const Gap(32),

                    // Title
                    Text(
                      percentage >= 80 ? 'Outstanding!' : 'Challenge Complete!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const Gap(8),

                    // Motivational message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const Gap(40),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResultStat(
                          icon: Icons.check_circle_rounded,
                          value: '$_score',
                          label: 'Correct',
                          color: success,
                          delay: 500,
                        ),
                        _buildResultStat(
                          icon: Icons.cancel_rounded,
                          value: '${_questions.length - _score}',
                          label: 'Wrong',
                          color: Colors.redAccent,
                          delay: 600,
                        ),
                        _buildResultStat(
                          icon: Icons.star_rounded,
                          value: '${percentage.round()}%',
                          label: 'Score',
                          color: warning,
                          delay: 700,
                        ),
                      ],
                    ),

                    const Gap(40),

                    // XP earned
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFFFD700),
                            size: 28,
                          ),
                          const Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'XP Earned',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Consumer(
                                builder: (context, ref, child) {
                                  final streakAsync = ref.watch(
                                    dailyChallengeStreakProvider,
                                  );
                                  return streakAsync.when(
                                    data: (streak) {
                                      final baseXP = DailyChallengeService
                                              .baseXPReward *
                                          _score ~/
                                          _questions.length;
                                      final streakBonus =
                                          streak * DailyChallengeService.streakBonusXP;
                                      return Text(
                                        '${baseXP + streakBonus} XP',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          color: const Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                    loading: () => Text(
                                      'Calculating...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        color: const Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    error: (_, _) => Text(
                                      '0 XP',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        color: const Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 800.ms)
                        .fade(duration: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const Spacer(),

                    // Back button
                    Container(
                      width: double.infinity,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.home_rounded, size: 22),
                        label: Text(
                          'Back to Home',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ).animate(delay: 900.ms).fade().slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Check if already completed today
    final isAvailableAsync = ref.watch(isChallengeAvailableProvider);

    return isAvailableAsync.when(
      data: (isAvailable) {
        if (!isAvailable) {
          return _buildAlreadyCompletedScreen(context, isDark, primary, secondary);
        }

        return _buildChallengeScreen(context, isDark, primary, secondary, warning);
      },
      loading: () => _buildLoadingScreen(context, isDark, primary),
      error: (error, stack) => _buildErrorScreen(
        context,
        isDark,
        primary,
        error.toString(),
      ),
    );
  }

  /// Loading screen
  Widget _buildLoadingScreen(
    BuildContext context,
    bool isDark,
    Color primary,
  ) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [primary.withOpacity(0.8), const Color(0xFF1E0A3C)]
                : [primary, primary.withOpacity(0.8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const Gap(16),
              Text(
                'Loading challenge...',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Error screen
  Widget _buildErrorScreen(
    BuildContext context,
    bool isDark,
    Color primary,
    String error,
  ) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [primary.withOpacity(0.8), const Color(0xFF1E0A3C)]
                : [primary, primary.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const Gap(16),
                  Text(
                    'Oops! Something went wrong',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const Gap(32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Already completed today screen
  Widget _buildAlreadyCompletedScreen(
    BuildContext context,
    bool isDark,
    Color primary,
    Color secondary,
  ) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [primary.withOpacity(0.9), const Color(0xFF1E0A3C)]
                : [primary, secondary.withOpacity(0.9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Checkmark icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),

                const Gap(32),

                Text(
                  'Challenge Complete!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fade().slideY(begin: 0.3),

                const Gap(8),

                Text(
                  'You\'ve already completed today\'s challenge.\nCome back tomorrow for a new one!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ).animate(delay: 200.ms).fade().slideY(begin: 0.2),

                const Gap(40),

                // Countdown timer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            'Next Challenge In',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCountdownBlock(
                            _timeRemaining.inHours.toString().padLeft(2, '0'),
                            'Hours',
                          ),
                          const Gap(12),
                          Text(
                            ':',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(12),
                          _buildCountdownBlock(
                            _timeRemaining.inMinutes.remainder(60).toString().padLeft(2, '0'),
                            'Minutes',
                          ),
                          const Gap(12),
                          Text(
                            ':',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(12),
                          _buildCountdownBlock(
                            _timeRemaining.inSeconds.remainder(60).toString().padLeft(2, '0'),
                            'Seconds',
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fade().scale(begin: const Offset(0.95, 0.95)),

                const Spacer(),

                // Streak info
                Consumer(
                  builder: (context, ref, child) {
                    final streakAsync = ref.watch(dailyChallengeStreakProvider);
                    final longestAsync = ref.watch(
                      dailyChallengeLongestStreakProvider,
                    );

                    return streakAsync.when(
                      data: (streak) => longestAsync.when(
                        data: (longest) => _buildStreakInfo(
                          streak: streak,
                          longest: longest,
                          isDark: isDark,
                        ),
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    );
                  },
                ),

                const Gap(24),

                // Back button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    label: Text(
                      'Back',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownBlock(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo({
    required int streak,
    required int longest,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔥',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Gap(4),
                  Text(
                    '$streak',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              Text(
                'Current Streak',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 20,
                    color: Color(0xFFFFD700),
                  ),
                  const Gap(4),
                  Text(
                    '$longest',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              Text(
                'Best Streak',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Main challenge playing screen
  Widget _buildChallengeScreen(
    BuildContext context,
    bool isDark,
    Color primary,
    Color secondary,
    Color warning,
  ) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.quiz_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const Gap(16),
                    Text(
                      'No questions available',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Complete some quizzes first to build your question pool!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const Gap(32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                      ),
                      child: Text(
                        'Go Back',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [primary.withOpacity(0.95), const Color(0xFF1E0A3C)]
                : [primary, secondary.withOpacity(0.9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _score > _currentQuestionIndex / 2
                                    ? const Color(0xFF10B981)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Text(
                          '${_currentQuestionIndex + 1}/${_questions.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),

                    // Question counter and score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFD700),
                                    size: 18,
                                  ),
                                  const Gap(4),
                                  Text(
                                    '$_score',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFFFFD700),
                                size: 18,
                              ),
                              const Gap(4),
                              Text(
                                '2x XP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Question card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
                                letterSpacing: 1,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              question.questionText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF1E293B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),

                      const Gap(24),

                      // Answer options
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: question.options.length,
                          separatorBuilder: (_, _) => const Gap(12),
                          itemBuilder: (context, index) {
                            return _buildAnswerOption(
                              context,
                              option: question.options[index],
                              index: index,
                              correctIndex: question.correctIndex,
                              primary: primary,
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    BuildContext context, {
    required String option,
    required int index,
    required int correctIndex,
    required Color primary,
    required bool isDark,
  }) {
    final isCorrect = index == correctIndex;
    final isSelected = index == _selectedAnswer;
    final showResult = _isAnswered;

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (showResult) {
      if (isCorrect) {
        borderColor = const Color(0xFF10B981);
        backgroundColor = const Color(0xFF10B981).withOpacity(0.15);
        textColor = const Color(0xFF10B981);
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.redAccent;
        backgroundColor = Colors.redAccent.withOpacity(0.15);
        textColor = Colors.redAccent;
      } else {
        borderColor = Colors.white.withOpacity(0.2);
        backgroundColor = Colors.white.withOpacity(0.05);
        textColor = Colors.white.withOpacity(0.5);
      }
    } else {
      borderColor = Colors.white.withOpacity(0.25);
      backgroundColor = Colors.white.withOpacity(0.08);
      textColor = Colors.white;
    }

    final optionLabels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: showResult ? 2 : 1.5),
        ),
        child: Row(
          children: [
            // Option label
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: showResult && (isCorrect || (isSelected && !isCorrect))
                    ? borderColor
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                optionLabels[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: showResult &&
                          (isCorrect || (isSelected && !isCorrect))
                      ? Colors.white
                      : Colors.white,
                ),
              ),
            ),
            const Gap(16),

            // Option text
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),

            // Result icon
            if (showResult)
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isSelected
                    ? Icons.cancel_rounded
                    : null,
                color: isCorrect
                    ? const Color(0xFF10B981)
                    : isSelected
                    ? Colors.redAccent
                    : Colors.transparent,
                size: 24,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(
      begin: 0.05 * (index + 1),
      end: 0,
      delay: Duration(milliseconds: 50 * index),
    );
  }

  Widget _buildResultStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    int delay = 0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const Gap(4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fade().scale(
      begin: const Offset(0.9, 0.9),
    );
  }
}

/// ==================== DAILY CHALLENGE CARD (for home screen) ====================

class DailyChallengeCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const DailyChallengeCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primary = Color(0xFF5B13EC);
    const secondary = Color(0xFF9333EA);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isAvailableAsync = ref.watch(isChallengeAvailableProvider);
    final streakAsync = ref.watch(dailyChallengeStreakProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [primary.withOpacity(0.8), secondary.withOpacity(0.6)]
                : [primary, secondary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Trophy icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Challenge',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(2),
                            isAvailableAsync.when(
                              data: (available) => streakAsync.when(
                                data: (streak) => Text(
                                  available
                                      ? streak > 0
                                          ? '🔥 $streak Day Streak'
                                          : 'Start your streak!'
                                      : 'Come back tomorrow!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                error: (_, _) => const SizedBox(),
                              ),
                              loading: () => const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              error: (_, _) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                      // Arrow or checkmark
                      isAvailableAsync.when(
                        data: (available) => Icon(
                          available
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        error: (_, _) => const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const Gap(16),

                  // 7-day mini calendar
                  Consumer(
                    builder: (context, ref, child) {
                      final calendarAsync = ref.watch(streakCalendarProvider);
                      return calendarAsync.when(
                        data: (calendar) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: calendar.days.map((day) {
                            return _buildMiniDay(
                              context,
                              day: day,
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                        loading: () => const SizedBox(
                          height: 32,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        error: (_, _) => const SizedBox(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDay(
    BuildContext context, {
    required StreakDay day,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.isCompleted
                ? const Color(0xFF10B981)
                : day.isToday
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.1),
            border: day.isToday
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: day.isCompleted
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
        const Gap(4),
        Text(
          _getDayAbbreviation(day.date),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
