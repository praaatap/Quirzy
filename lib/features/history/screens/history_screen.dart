import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/providers/quiz_history_provider.dart';
import 'package:quirzy/features/history/screens/quiz_stats_screen.dart';
import 'package:quirzy/core/widgets/loading/shimmer_loading.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==========================================
// REDESIGNED HISTORY SCREEN
// Matches HTML reference design exactly
// ==========================================

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedTab = 0; // 0: Quizzes, 1: Progress, 2: Stats

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizHistoryProvider.notifier).loadHistory();
    });
  }

  void _navigateToStats(Map<String, dynamic> quiz) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizStatsScreen(quizData: quiz),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await ref.read(quizHistoryProvider.notifier).refreshNow();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors matching HTML reference
    const primaryColor = Color(0xFF5B13EC);
    const primaryLight = Color(0xFFEFE9FD);
    final bgColor = isDark ? const Color(0xFF161022) : const Color(0xFFF9F8FC);
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF664C9A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Content
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: primaryColor,
              child:
                  CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          // App Bar
                          SliverToBoxAdapter(child: _buildAppBar(textMain)),

                          // Hero Section
                          SliverToBoxAdapter(
                            child: _buildHeroSection(
                              textMain,
                              textSub,
                              primaryColor,
                              isDark,
                            ),
                          ),

                          // Tab Bar
                          SliverToBoxAdapter(
                            child: _buildTabBar(isDark, primaryColor, textSub),
                          ),

                          // Content based on selection
                          if (_selectedTab == 0) ...[
                            // Stats Cards
                            SliverToBoxAdapter(
                              child: _buildStatsCards(
                                isDark,
                                primaryColor,
                                textMain,
                                textSub,
                              ),
                            ),
                            // Recent History Header
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(
                                textMain,
                                primaryColor,
                              ),
                            ),
                            // Quiz List
                            _buildQuizList(
                              isDark,
                              textMain,
                              textSub,
                              primaryColor,
                              primaryLight,
                            ),
                          ] else if (_selectedTab == 1) ...[
                            // Progress Tab Placeholder
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                          Icons.bar_chart_rounded,
                                          size: 48,
                                          color: textSub.withOpacity(0.5),
                                          // ignore: dead_code
                                        )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .scale(
                                          begin: const Offset(1, 1),
                                          end: const Offset(1.1, 1.1),
                                          duration: 1000.ms,
                                        ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Progress & Analytics\nComing Soon",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textSub,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Stats Tab Placeholder or content
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: _buildStatsCards(
                                  isDark,
                                  primaryColor,
                                  textMain,
                                  textSub,
                                ),
                              ),
                            ),
                          ],

                          // Bottom spacing for CTA
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),
            ),

            // Floating CTA Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: _buildCTAButton(primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color textMain) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'History',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    Color textMain,
    Color textSub,
    Color primaryColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your Learning\n'),
                    TextSpan(
                      text: 'Journey',
                      style: TextStyle(
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 800.ms, delay: 100.ms)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
                'Review your past achievements and keep growing.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSub,
                ),
              )
              .animate()
              .fade(duration: 800.ms, delay: 200.ms)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, Color primaryColor, Color textSub) {
    final tabs = ['Quizzes', 'Progress', 'Stats'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        borderRadius: BorderRadius.circular(9999), // Full rounded
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedTab = entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : textSub,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards(
    bool isDark,
    Color primaryColor,
    Color textMain,
    Color textSub,
  ) {
    final quizzes = ref.watch(quizHistoryProvider.select((s) => s.quizzes));
    final totalQuizzes = quizzes.length;

    // Calculate average score
    int totalScore = 0;
    int totalQuestions = 0;
    for (final quiz in quizzes) {
      totalScore += (quiz['score'] ?? 0) as int;
      totalQuestions +=
          (quiz['totalQuestions'] ?? quiz['questionCount'] ?? 0) as int;
    }
    final avgScore = totalQuestions > 0
        ? (totalScore / totalQuestions * 100).round()
        : 0;

    // Count this week's quizzes
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeekCount = quizzes.where((q) {
      final createdAt = q['createdAt'] != null
          ? DateTime.parse(q['createdAt'])
          : DateTime.now();
      return createdAt.isAfter(weekAgo);
    }).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          // Total Quizzes Card
          Expanded(
            child: Container(
              height: 96,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  // Glow effect
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL QUIZZES',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSub,
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$totalQuizzes',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '+$thisWeekCount this week',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: primaryColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avg Score Card
          Expanded(
            child: Container(
              height: 96,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF3F4F6),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AVG. SCORE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSub,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$avgScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(Color textMain, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent History',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Text(
              'View All',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(
    bool isDark,
    Color textMain,
    Color textSub,
    Color primaryColor,
    Color primaryLight,
  ) {
    final isLoading = ref.watch(quizHistoryProvider.select((s) => s.isLoading));
    final quizzes = ref.watch(quizHistoryProvider.select((s) => s.quizzes));

    if (isLoading && quizzes.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: ShimmerPlaceholders.historyList(itemCount: 4),
        ),
      );
    }

    if (quizzes.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(
          isDark,
          textMain,
          textSub,
          primaryColor,
          primaryLight,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildQuizCard(
            quizzes[index],
            isDark,
            textMain,
            textSub,
            primaryColor,
            primaryLight,
          );
        }, childCount: quizzes.length),
      ),
    );
  }

  Widget _buildQuizCard(
    Map<String, dynamic> quiz,
    bool isDark,
    Color textMain,
    Color textSub,
    Color primaryColor,
    Color primaryLight,
  ) {
    final title = quiz['quizTitle'] ?? quiz['title'] ?? 'Untitled Quiz';
    final totalQuestions = quiz['totalQuestions'] ?? quiz['questionCount'] ?? 0;
    final score = quiz['score'] ?? 0;
    final createdAt = quiz['createdAt'] != null
        ? DateTime.parse(quiz['createdAt'])
        : DateTime.now();

    final percentage = totalQuestions > 0
        ? (score / totalQuestions * 100).round()
        : 0;
    final isIncomplete = quiz['isIncomplete'] == true || totalQuestions == 0;

    // Format date
    final now = DateTime.now();
    String dateText;
    if (_isSameDay(createdAt, now)) {
      dateText = 'Today';
    } else if (_isSameDay(createdAt, now.subtract(const Duration(days: 1)))) {
      dateText = 'Yesterday';
    } else {
      dateText = '${_getMonthName(createdAt.month)} ${createdAt.day}';
    }

    // Score colors
    final (Color scoreBg, Color scoreText) = _getScoreColors(
      percentage,
      isIncomplete,
    );

    // Icon and colors
    final (IconData icon, Color iconBg, Color iconColor) = _getSubjectStyle(
      title,
      primaryColor,
      primaryLight,
    );

    return GestureDetector(
      onTap: () => _navigateToStats(quiz),
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF27272A)
                        : Colors.transparent,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textMain,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isIncomplete
                                ? '$dateText • Incomplete'
                                : '$dateText • $totalQuestions questions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSub,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scoreBg,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        isIncomplete ? '--' : '$percentage%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scoreText,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 400.ms)
              .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  (Color, Color) _getScoreColors(int percentage, bool isIncomplete) {
    if (isIncomplete) {
      return (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    }
    if (percentage >= 80) {
      return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)); // Green
    } else if (percentage >= 50) {
      return (const Color(0xFFFFF8E1), const Color(0xFFFBC02D)); // Yellow
    } else {
      return (const Color(0xFFFFEBEE), const Color(0xFFC62828)); // Red
    }
  }

  (IconData, Color, Color) _getSubjectStyle(
    String title,
    Color primaryColor,
    Color primaryLight,
  ) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('biology') || lowerTitle.contains('science')) {
      return (
        Icons.science_rounded,
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      );
    } else if (lowerTitle.contains('history') ||
        lowerTitle.contains('european')) {
      return (
        Icons.history_edu_rounded,
        const Color(0xFFFFF3E0),
        const Color(0xFFEF6C00),
      );
    } else if (lowerTitle.contains('art') || lowerTitle.contains('movement')) {
      return (Icons.brush_rounded, primaryLight, primaryColor);
    } else if (lowerTitle.contains('python') ||
        lowerTitle.contains('code') ||
        lowerTitle.contains('programming')) {
      return (
        Icons.code_rounded,
        const Color(0xFFF3F4F6),
        const Color(0xFF6B7280),
      );
    } else if (lowerTitle.contains('math') || lowerTitle.contains('calculus')) {
      return (
        Icons.calculate_rounded,
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      );
    } else if (lowerTitle.contains('chemistry')) {
      return (
        Icons.science_rounded,
        const Color(0xFFFCE4EC),
        const Color(0xFFC2185B),
      );
    } else if (lowerTitle.contains('geography') ||
        lowerTitle.contains('world')) {
      return (
        Icons.public_rounded,
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      );
    } else if (lowerTitle.contains('language') ||
        lowerTitle.contains('vocab') ||
        lowerTitle.contains('french')) {
      return (
        Icons.translate_rounded,
        const Color(0xFFFFF3E0),
        const Color(0xFFEF6C00),
      );
    } else {
      return (Icons.quiz_rounded, primaryLight, primaryColor);
    }
  }

  Widget _buildCTAButton(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(tabIndexProvider.notifier).state = 0;
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Start New Quiz',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color textMain,
    Color textSub,
    Color primaryColor,
    Color primaryLight,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_rounded, size: 64, color: primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'No Quizzes Yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'It looks a bit quiet here. Create your first quiz from your notes to get started!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: textSub,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
