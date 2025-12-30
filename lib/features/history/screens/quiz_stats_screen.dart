import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';

class QuizStatsScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizStatsScreen({super.key, required this.quizData});

  @override
  State<QuizStatsScreen> createState() => _QuizStatsScreenState();
}

class _QuizStatsScreenState extends State<QuizStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late ConfettiController _confettiController;

  // Staggered Animations
  late Animation<double> _chartOpacity;
  late Animation<Offset> _chartSlide;
  late Animation<double> _gridOpacity;
  late Animation<Offset> _gridSlide;
  late Animation<double> _btnOpacity;
  late Animation<Offset> _btnSlide;

  // Use the same primary color as other screens
  static const primaryColor = Color(0xFF5B13EC);

  @override
  void initState() {
    super.initState();

    // 1. Setup Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // 2. Setup Entrance Animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Chart enters first
    _chartOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _chartSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Grid enters second
    _gridOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _gridSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Button enters last
    _btnOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _btnSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    // Check score to trigger confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final score = widget.quizData['score'] ?? 0;
      final total =
          widget.quizData['questionCount'] ??
          widget.quizData['totalQuestions'] ??
          10;
      // Trigger confetti if score is >= 50%
      if (total > 0 && (score / total) >= 0.5) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "--:--";
    final duration = Duration(seconds: seconds);
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // Helper to determine Grade Colors and Text
  Map<String, dynamic> _getGradeInfo(double percentage) {
    if (percentage >= 90) {
      return {
        'text': 'Excellent!',
        'color': const Color(0xFF10B981), // Emerald
        'icon': Icons.emoji_events_rounded,
        'bg': const Color(0xFF10B981).withOpacity(0.1),
      };
    }
    if (percentage >= 70) {
      return {
        'text': 'Great Job!',
        'color': const Color(0xFF3B82F6), // Blue
        'icon': Icons.thumb_up_rounded,
        'bg': const Color(0xFF3B82F6).withOpacity(0.1),
      };
    }
    if (percentage >= 50) {
      return {
        'text': 'Good Effort',
        'color': const Color(0xFFF59E0B), // Amber
        'icon': Icons.sentiment_satisfied_rounded,
        'bg': const Color(0xFFF59E0B).withOpacity(0.1),
      };
    }
    return {
      'text': 'Keep Trying',
      'color': const Color(0xFFEF4444), // Red
      'icon': Icons.refresh_rounded,
      'bg': const Color(0xFFEF4444).withOpacity(0.1),
    };
  }

  // ==================== NEW: SHOW REVIEW SHEET ====================
  void _showReviewSheet(BuildContext context) {
    // Check if detailed question data exists (e.g. 'questions' list)
    // Note: If fetching from history API, ensure your backend includes this data
    final List<dynamic>? questions = widget.quizData['questions'];
    final List<dynamic>? userAnswers =
        widget.quizData['userAnswers']; // Indices

    // If we don't have detailed data (e.g. simple history summary), show alert
    if (questions == null || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Detailed review is not available for this record.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey[800],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF1E1730) : Colors.white;
        final textMain = isDark ? Colors.white : const Color(0xFF120D1B);

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle Bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Answer Key",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: textMain),
                    ),
                  ],
                ),
              ),

              // List of Questions
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 0,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    // Safe access to data
                    final String qText =
                        q['questionText'] ?? 'Unknown Question';
                    final List<dynamic> options = q['options'] ?? [];
                    final int correctIdx = q['correctAnswer'] ?? 0;

                    // Handle if user answers are stored differently (e.g. map or list)
                    int? userIdx;
                    if (userAnswers != null && index < userAnswers.length) {
                      userIdx = userAnswers[index]; // Assuming List<int>
                    } else if (q['userSelectedAnswer'] != null) {
                      userIdx =
                          q['userSelectedAnswer']; // Assuming stored in question obj
                    }

                    final bool isCorrect = userIdx == correctIdx;
                    final String correctTxt =
                        (correctIdx >= 0 && correctIdx < options.length)
                        ? options[correctIdx]
                        : 'Unknown';
                    final String userTxt =
                        (userIdx != null &&
                            userIdx >= 0 &&
                            userIdx < options.length)
                        ? options[userIdx]
                        : 'Skipped';

                    return _buildReviewCard(
                      context,
                      index + 1,
                      qText,
                      userTxt,
                      correctTxt,
                      isCorrect,
                      isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    int num,
    String question,
    String userAnswer,
    String correctAnswer,
    bool isCorrect,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF1E1730) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE2E8F0);
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA78BFA) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Q$num",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          // User Answer
          if (!isCorrect)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          color: textSub,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: "You: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: userAnswer,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Correct Answer
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      color: textSub,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(
                        text: "Correct: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: correctAnswer,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors matching HomeScreen
    final bgColor = isDark ? const Color(0xFF161022) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1E1730) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA78BFA) : const Color(0xFF64748B);

    // Extract Data
    final title =
        widget.quizData['title'] ??
        widget.quizData['quizTitle'] ??
        'Quiz Result';
    final score = widget.quizData['score'] ?? 0;
    final totalQs =
        widget.quizData['questionCount'] ??
        widget.quizData['totalQuestions'] ??
        10;
    final timeSeconds = widget.quizData['timeTaken'] ?? 0;

    final percentage = totalQs > 0 ? (score / totalQs) * 100 : 0.0;
    final correct = score;
    final incorrect = totalQs - score;
    final accuracy = percentage.toStringAsFixed(0);
    final gradeInfo = _getGradeInfo(percentage);

    final dateStr = widget.quizData['createdAt'];
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        // Stack is used to overlay Confetti
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Main Content
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: bgColor,
                  expandedHeight: 0,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          border: isDark
                              ? Border.all(color: Colors.white12)
                              : Border.all(color: Colors.black12),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: textMain,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  centerTitle: true,
                  title: Text(
                    'Result Overview',
                    style: GoogleFonts.plusJakartaSans(
                      color: textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Chart Section with Staggered Animation
                      FadeTransition(
                        opacity: _chartOpacity,
                        child: SlideTransition(
                          position: _chartSlide,
                          child: _buildMainResultCard(
                            isDark,
                            surfaceColor,
                            textMain,
                            textSub,
                            title,
                            date,
                            correct,
                            incorrect,
                            gradeInfo,
                            percentage,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats Grid with Staggered Animation
                      FadeTransition(
                        opacity: _gridOpacity,
                        child: SlideTransition(
                          position: _gridSlide,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildStatTile(
                                isDark,
                                surfaceColor,
                                textMain,
                                'Correct',
                                '$correct',
                                Icons.check_circle_rounded,
                                const Color(0xFF10B981),
                              ),
                              _buildStatTile(
                                isDark,
                                surfaceColor,
                                textMain,
                                'Incorrect',
                                '$incorrect',
                                Icons.cancel_rounded,
                                const Color(0xFFEF4444),
                              ),
                              _buildStatTile(
                                isDark,
                                surfaceColor,
                                textMain,
                                'Duration',
                                _formatDuration(timeSeconds),
                                Icons.timer_rounded,
                                const Color(0xFF3B82F6),
                              ),
                              _buildStatTile(
                                isDark,
                                surfaceColor,
                                textMain,
                                'Accuracy',
                                '$accuracy%',
                                Icons.analytics_rounded,
                                const Color(0xFF8B5CF6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Button with Staggered Animation
                      FadeTransition(
                        opacity: _btnOpacity,
                        child: SlideTransition(
                          position: _btnSlide,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              // Review Sheet
                              onPressed: () => _showReviewSheet(context),
                              icon: const Icon(
                                Icons.playlist_add_check_rounded,
                              ),
                              label: Text(
                                'Review Answers',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),

            // 2. Confetti Overlay (Celebration!)
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF5B13EC),
                Color(0xFF10B981),
                Color(0xFFF59E0B),
                Color(0xFFEF4444),
                Color(0xFF3B82F6),
              ],
              gravity: 0.2,
              numberOfParticles: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainResultCard(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
    String title,
    DateTime date,
    int correct,
    int incorrect,
    Map<String, dynamic> gradeInfo,
    double percent,
  ) {
    final total = correct + incorrect;
    final double percentCorrect = total > 0 ? correct / total : 0.0;
    final double percentIncorrect = total > 0 ? incorrect / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: gradeInfo['bg'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(gradeInfo['icon'], color: gradeInfo['color'], size: 20),
                const SizedBox(width: 8),
                Text(
                  gradeInfo['text'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: gradeInfo['color'],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle for depth
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 65,
                    sections: [
                      PieChartSectionData(
                        value: percentCorrect,
                        color: const Color(0xFF10B981),
                        radius: 25,
                        showTitle: false,
                        badgeWidget: _buildBadge(
                          Icons.check,
                          const Color(0xFF10B981),
                        ),
                        badgePositionPercentageOffset: .98,
                      ),
                      PieChartSectionData(
                        value: percentIncorrect,
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        radius: 20,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percent.toInt()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: textMain,
                      ),
                    ),
                    Text(
                      'Score',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSub,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, y • h:mm a').format(date),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Small Badge on the Pie Chart
  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }

  Widget _buildStatTile(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
