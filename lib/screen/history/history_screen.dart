import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/screen/history/stats/quiz_stats_screen.dart';
import 'package:quirzy/service/quiz_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// ==========================================
// ANIMATED LIST ITEM (The Modern Effect)
// ==========================================

class _AnimatedHistoryCard extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedHistoryCard({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedHistoryCard> createState() => _AnimatedHistoryCardState();
}

class _AnimatedHistoryCardState extends State<_AnimatedHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// ==========================================
// HISTORY SCREEN
// ==========================================

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _quizzes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizService = ref.read(quizServiceProvider);
      final quizzes = await quizService.getQuizHistory();

      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToStats(Map<String, dynamic> quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizStatsScreen(quizData: quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Important for the modern look
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Background Blobs (Same as settings)
          RepaintBoundary(
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary
                          .withOpacity(isDark ? 0.05 : 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary
                          .withOpacity(isDark ? 0.04 : 0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content with SliverScroll
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadQuizHistory,
              color: theme.colorScheme.primary,
              edgeOffset: 100, // Push spinner down a bit
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                slivers: [
                  // Modern Floating AppBar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    stretch: true,
                    expandedHeight: 80,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 16),
                      title: Text(
                        'Your Attempts',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        padding: const EdgeInsets.only(right: 20),
                        onPressed: _loadQuizHistory,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Content
                  if (_isLoading)
                    SliverFillRemaining(child: _buildLoadingState())
                  else if (_error != null)
                    SliverFillRemaining(child: _buildErrorState(theme))
                  else if (_quizzes.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState(theme))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _AnimatedHistoryCard(
                              index: index,
                              child: _buildQuizCard(
                                  _quizzes[index], theme, index),
                            );
                          },
                          childCount: _quizzes.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                size: 60, color: theme.colorScheme.error),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops!',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadQuizHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Attempts Yet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a quiz to see your\nperformance stats here!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                ref.read(tabIndexProvider.notifier).state = 0;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Quiz',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(
      Map<String, dynamic> quiz, ThemeData theme, int index) {
    // Data Normalization
    final title = quiz['quizTitle'] ?? quiz['title'] ?? 'Untitled Quiz';
    final totalQuestions =
        quiz['totalQuestions'] ?? quiz['questionCount'] ?? 0;
    final score = quiz['score'] ?? 0;
    final createdAt = quiz['createdAt'] != null
        ? DateTime.parse(quiz['createdAt'])
        : DateTime.now();

    // Score Calculation & Coloring
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) : 0.0;
    Color statusColor;
    if (percentage >= 0.8) {
      statusColor = Colors.green;
    } else if (percentage >= 0.5) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24), // More rounded
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _navigateToStats(quiz),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 1. Circular Percentage Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: percentage,
                        backgroundColor: statusColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // 2. Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniChip(
                            theme: theme,
                            icon: Icons.check_circle_rounded,
                            text: '$score/$totalQuestions',
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniChip(
                              theme: theme,
                              icon: Icons.access_time_rounded,
                              text: timeago.format(createdAt,
                                  allowFromNow: true),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Chevron
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip({
    required ThemeData theme,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: isDark ? color.withOpacity(0.8) : color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}