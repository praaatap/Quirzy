import 'dart:math';
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

  @override
  void initState() {
    super.initState();

    // 1. Setup Confetti
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // 2. Setup Entrance Animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Chart enters first
    _chartOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _chartSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    // Grid enters second
    _gridOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _gridSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );

    // Button enters last
    _btnOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _btnSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    _entranceController.forward();

    // Check score to trigger confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final score = widget.quizData['score'] ?? 0;
      final total = widget.quizData['questionCount'] ??
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
        'color': Colors.greenAccent[700],
        'icon': Icons.emoji_events_rounded
      };
    }
    if (percentage >= 70) {
      return {
        'text': 'Great Job!',
        'color': Colors.teal,
        'icon': Icons.thumb_up_rounded
      };
    }
    if (percentage >= 50) {
      return {
        'text': 'Good Effort',
        'color': Colors.orange,
        'icon': Icons.sentiment_satisfied_rounded
      };
    }
    return {
      'text': 'Keep Trying',
      'color': Colors.redAccent,
      'icon': Icons.refresh_rounded
    };
  }

  // ==================== NEW: SHOW REVIEW SHEET ====================
  void _showReviewSheet(BuildContext context) {
    // Check if detailed question data exists (e.g. 'questions' list)
    // Note: If fetching from history API, ensure your backend includes this data
    final List<dynamic>? questions = widget.quizData['questions'];
    final List<dynamic>? userAnswers = widget.quizData['userAnswers']; // Indices
    
    // If we don't have detailed data (e.g. simple history summary), show alert
    if (questions == null || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Detailed review is not available for this record.',
            style: GoogleFonts.poppins(),
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // List of Questions
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  // Safe access to data
                  final String qText = q['questionText'] ?? 'Unknown Question';
                  final List<dynamic> options = q['options'] ?? [];
                  final int correctIdx = q['correctAnswer'] ?? 0;
                  
                  // Handle if user answers are stored differently (e.g. map or list)
                  int? userIdx;
                  if (userAnswers != null && index < userAnswers.length) {
                    userIdx = userAnswers[index]; // Assuming List<int>
                  } else if (q['userSelectedAnswer'] != null) {
                    userIdx = q['userSelectedAnswer']; // Assuming stored in question obj
                  }

                  final bool isCorrect = userIdx == correctIdx;
                  final String correctTxt = (correctIdx >= 0 && correctIdx < options.length) 
                      ? options[correctIdx] 
                      : 'Unknown';
                  final String userTxt = (userIdx != null && userIdx >= 0 && userIdx < options.length) 
                      ? options[userIdx] 
                      : 'Skipped';

                  return _buildReviewCard(
                    context, 
                    index + 1, 
                    qText, 
                    userTxt, 
                    correctTxt, 
                    isCorrect
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, int num, String question, String userAnswer, String correctAnswer, bool isCorrect) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$num",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // User Answer
          if (!isCorrect)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.close, size: 16, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: theme.colorScheme.onSurface, fontSize: 13),
                        children: [
                          TextSpan(text: "Your Answer: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: userAnswer, style: TextStyle(color: Colors.red[400])),
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
              Icon(Icons.check, size: 16, color: Colors.green[600]),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(color: theme.colorScheme.onSurface, fontSize: 13),
                    children: [
                      TextSpan(text: "Correct Answer: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: correctAnswer, style: TextStyle(color: Colors.green[600])),
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
    final theme = Theme.of(context);

    // Extract Data
    final title = widget.quizData['title'] ??
        widget.quizData['quizTitle'] ??
        'Quiz Result';
    final score = widget.quizData['score'] ?? 0;
    final totalQs = widget.quizData['questionCount'] ??
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

    return 
    SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        // Stack is used to overlay Confetti
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Main Content
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  expandedHeight: 0,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: theme.colorScheme.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    'Result Overview',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
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
                          child: _buildMainResultCard(theme, title, date, correct,
                              incorrect, gradeInfo, percentage),
                        ),
                      ),
      
                      const SizedBox(height: 32),
      
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
                            childAspectRatio: 1.4,
                            children: [
                              _buildStatTile(theme, 'Correct', '$correct',
                                  Icons.check_circle_outline_rounded, Colors.green),
                              _buildStatTile(
                                  theme,
                                  'Incorrect',
                                  '$incorrect',
                                  Icons.cancel_outlined,
                                  Colors.redAccent),
                              _buildStatTile(
                                  theme,
                                  'Duration',
                                  _formatDuration(timeSeconds),
                                  Icons.timer_outlined,
                                  theme.colorScheme.primary),
                              _buildStatTile(
                                  theme,
                                  'Accuracy',
                                  '$accuracy%',
                                  Icons.analytics_outlined,
                                  theme.colorScheme.tertiary),
                            ],
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 40),
      
                      // Action Button with Staggered Animation
                      FadeTransition(
                        opacity: _btnOpacity,
                        child: SlideTransition(
                          position: _btnSlide,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              // UPDATED: Now calls the review sheet
                              onPressed: () => _showReviewSheet(context),
                              icon: const Icon(Icons.playlist_add_check_rounded),
                              label: Text('Review Answers',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 4,
                                shadowColor:
                                    theme.colorScheme.primary.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
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
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              gravity: 0.2,
              numberOfParticles: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainResultCard(
      ThemeData theme,
      String title,
      DateTime date,
      int correct,
      int incorrect,
      Map<String, dynamic> gradeInfo,
      double percent) {
    final total = correct + incorrect;
    final double percentCorrect = total > 0 ? correct / total : 0.0;
    final double percentIncorrect = total > 0 ? incorrect / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32), // More rounded
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(gradeInfo['icon'], color: gradeInfo['color'], size: 28),
              const SizedBox(width: 8),
              Text(
                gradeInfo['text'],
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: gradeInfo['color'],
                ),
              ),
            ],
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
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                        color: Colors.greenAccent[400],
                        radius: 25,
                        showTitle: false,
                        badgeWidget:
                            _buildBadge(Icons.check, Colors.greenAccent[400]!),
                        badgePositionPercentageOffset: .98,
                      ),
                      PieChartSectionData(
                        value: percentIncorrect,
                        color: Colors.redAccent[100],
                        radius: 20, // Slightly smaller for effect
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Score',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
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
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM d, y • h:mm a').format(date),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildStatTile(ThemeData theme, String label, String value,
      IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
        boxShadow: [
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
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}