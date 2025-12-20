import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';

class QuizCompleteScreen extends ConsumerStatefulWidget {
  final String quizTitle;
  final String quizId;
  final int score;
  final int totalQuestions;
  final List<bool> userAnswers;
  final List<int> userSelectedAnswers;
  final List<Map<String, dynamic>> questions;
  final String? difficulty;

  const QuizCompleteScreen({
    super.key,
    required this.quizTitle,
    required this.quizId,
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
  late TabController _tabController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;

  // Track save status
  bool _isSaving = false;
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Initialize Confetti safely
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start Animations
    _entranceController.forward();

    // ⚡️ 1. SAVE HISTORY IMMEDIATELY
    // We do this inside addPostFrameCallback to ensure the widget is built first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveQuizResult();
      _playConfettiEffect();
    });
  }

  void _playConfettiEffect() {
    try {
      final percentage = (widget.score / widget.totalQuestions * 100).round();
      if (percentage >= 70) {
        // Add a slight delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _confettiController.play();
        });
      }
    } catch (e) {
      debugPrint("Confetti error ignored: $e");
    }
  }

  // ⚡️ 2. ROBUST SAVE FUNCTION
  Future<void> _saveQuizResult() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      debugPrint("💾 STARTING SAVE: Quiz ID ${widget.quizId}");

      final quizService = ref.read(quizServiceProvider);

      await quizService.saveQuizResult(
        quizId: widget.quizId,
        quizTitle: widget.quizTitle,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        questions: widget.questions,
        userSelectedAnswers: widget.userSelectedAnswers,
        timeTaken: 0,
      );

      if (mounted) {
        setState(() {
          _saveSuccess = true;
          _isSaving = false;
        });
        debugPrint("✅ HISTORY SAVED SUCCESSFULLY");
      }
    } catch (e) {
      debugPrint("❌ FAILED TO SAVE HISTORY: $e");
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not save history: ${e.toString()}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entranceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _shareResults() {
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    Share.share(
      'I scored $percentage% on ${widget.quizTitle} in Quirzy! 🚀\nCan you beat my score?',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- Decorative Background Circles ---
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.05),
              ),
            ),
          ),

          // --- Main Content ---
          Column(
            children: [
              // Custom AppBar Area
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        "Summary",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: _shareResults,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.share_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar Container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: "Overview"),
                    Tab(text: "Review Answers"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Tab View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ScoreOverviewTab(
                      widget: widget,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      saveSuccess: _saveSuccess, // Pass save status to UI
                    ),
                    _AnalysisListTab(widget: widget),
                  ],
                ),
              ),
            ],
          ),

          // --- Confetti Layer (Top) ---
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

// =============================================================================
// TAB 1: MODERN SCORE OVERVIEW
// =============================================================================

class _ScoreOverviewTab extends StatelessWidget {
  final QuizCompleteScreen widget;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool saveSuccess;

  const _ScoreOverviewTab({
    required this.widget,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.saveSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (widget.score / widget.totalQuestions * 100).round();
    final performance = _getPerformanceData(percentage);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // 1. Modern Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      performance['color'].withOpacity(0.85),
                      performance['color'],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: performance['color'].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        performance['icon'],
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      performance['text'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Save Status Indicator
                    if (saveSuccess)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_done,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Saved to History",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Correct',
                      value: '${widget.score}',
                      color: Colors.green,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Wrong',
                      value: '${widget.totalQuestions - widget.score}',
                      color: Colors.redAccent,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Completed',
                      value: '100%',
                      color: Colors.blue,
                      icon: Icons.done_all_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Total Qs',
                      value: '${widget.totalQuestions}',
                      color: Colors.orange,
                      icon: Icons.list_alt_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 3. Action Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Back to Home",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPerformanceData(int percentage) {
    if (percentage >= 90) {
      return {
        'text': 'Outstanding!',
        'color': Colors.green,
        'icon': Icons.emoji_events_rounded,
      };
    } else if (percentage >= 70) {
      return {
        'text': 'Great Job!',
        'color': Colors.blue,
        'icon': Icons.thumb_up_rounded,
      };
    } else if (percentage >= 50) {
      return {
        'text': 'Good Effort!',
        'color': Colors.orange,
        'icon': Icons.trending_up_rounded,
      };
    } else {
      return {
        'text': 'Keep Learning',
        'color': Colors.redAccent,
        'icon': Icons.school_rounded,
      };
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 2: OPTIMIZED ANALYSIS LIST
// =============================================================================

class _AnalysisListTab extends StatelessWidget {
  final QuizCompleteScreen widget;

  const _AnalysisListTab({required this.widget});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        return _QuestionAnalysisCard(
          index: index,
          question: widget.questions[index],
          isCorrect: widget.userAnswers[index],
          userSelectedIndex: widget.userSelectedAnswers[index],
        );
      },
    );
  }
}

class _QuestionAnalysisCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> question;
  final bool isCorrect;
  final int userSelectedIndex;

  const _QuestionAnalysisCard({
    required this.index,
    required this.question,
    required this.isCorrect,
    required this.userSelectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = (question['options'] as List<dynamic>).cast<String>();
    final correctAnswerIndex = question['correctAnswer'] as int;
    final userAnswer =
        userSelectedIndex >= 0 && userSelectedIndex < options.length
        ? options[userSelectedIndex]
        : 'Skipped';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20), // Matches other cards
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isCorrect ? Colors.green : Colors.redAccent)
                      .withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            question['questionText'] as String,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            isCorrect ? Icons.keyboard_arrow_down : Icons.close,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          children: [
            if (!isCorrect) ...[
              _buildInfoRow(
                context,
                "Your Answer",
                userAnswer,
                Colors.red.shade700,
                Colors.red.withOpacity(0.1),
                Icons.close,
              ),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(
              context,
              "Correct Answer",
              options[correctAnswerIndex],
              Colors.green.shade700,
              Colors.green.withOpacity(0.1),
              Icons.check,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String text,
    Color textColor,
    Color bgColor,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveTextColor = isDark ? textColor.withOpacity(0.9) : textColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: effectiveTextColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: effectiveTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
