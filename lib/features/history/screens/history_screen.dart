import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/providers/tab_index_provider.dart';
import 'package:quirzy/providers/quiz_history_provider.dart';
import 'package:quirzy/features/history/screens/quiz_stats_screen.dart';
import 'package:quirzy/shared/widgets/loading/shimmer_loading.dart';
import 'package:quirzy/core/platform/platform_adaptive.dart';
import 'package:timeago/timeago.dart' as timeago;

// ==========================================
// HIGH-PERFORMANCE HISTORY SCREEN
// ==========================================
// Optimizations:
// - const widgets where possible
// - RepaintBoundary for isolated renders
// - AutomaticKeepAlive for tab caching
// - Sliver-based lazy loading
// - Efficient selectors to minimize rebuilds

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );

    _headerSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizHistoryProvider.notifier).loadHistory();
      _headerAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background - wrapped in RepaintBoundary (static, render once)
          const RepaintBoundary(child: _BackgroundDecoration()),

          // Main Content
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              edgeOffset: 80,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: PlatformAdaptive.scrollPhysics,
                ),
                slivers: [
                  // Header - animated once
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _headerSlideAnim,
                      child: FadeTransition(
                        opacity: _headerFadeAnim,
                        child: _HistoryHeader(onRefresh: _onRefresh),
                      ),
                    ),
                  ),

                  // Stats Cards - only rebuild when stats change
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _headerFadeAnim,
                      child: const _StatsSummary(),
                    ),
                  ),

                  // Quiz List - efficient selector
                  _buildQuizList(theme, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(ThemeData theme, bool isDark) {
    // Use select to only rebuild when specific properties change
    final isLoading = ref.watch(quizHistoryProvider.select((s) => s.isLoading));
    final error = ref.watch(quizHistoryProvider.select((s) => s.error));
    final quizzes = ref.watch(quizHistoryProvider.select((s) => s.quizzes));

    if (isLoading && quizzes.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: ShimmerPlaceholders.historyList(itemCount: 5),
        ),
      );
    }

    if (error != null && quizzes.isEmpty) {
      return SliverFillRemaining(
        child: _ErrorState(error: error, onRetry: _onRefresh),
      );
    }

    if (quizzes.isEmpty) {
      return SliverFillRemaining(
        child: _EmptyState(
          onStartQuiz: () {
            HapticFeedback.lightImpact();
            ref.read(tabIndexProvider.notifier).state = 0;
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _OptimizedQuizCard(
              key: ValueKey(
                quizzes[index]['_id'] ?? quizzes[index]['id'] ?? index,
              ),
              quiz: quizzes[index],
              index: index,
              onTap: () => _navigateToStats(quizzes[index]),
            );
          },
          childCount: quizzes.length,
          // Add extent for better scrolling performance
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}

// ==========================================
// BACKGROUND DECORATION (STATIC)
// ==========================================

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Top gradient overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 400,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.14),
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.04 : 0.06),
                  theme.scaffoldBackgroundColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // Top-right primary blur blob
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.25),
                  theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.12),
                  theme.colorScheme.primary.withOpacity(0),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 80,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
        // Bottom-left secondary blur blob
        Positioned(
          bottom: 150,
          left: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.12 : 0.15),
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.06 : 0.08),
                  theme.colorScheme.secondary.withOpacity(0),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Accent glow
        Positioned(
          top: size.height * 0.4,
          right: -40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(isDark ? 0.08 : 0.1),
                  Colors.orange.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// HEADER (OPTIMIZED REBUILDS)
// ==========================================

class _HistoryHeader extends ConsumerWidget {
  final VoidCallback onRefresh;

  const _HistoryHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Only watch what we need
    final count = ref.watch(
      quizHistoryProvider.select((s) => s.quizzes.length),
    );
    final isRefreshing = ref.watch(
      quizHistoryProvider.select((s) => s.isRefreshing),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with icon and refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'History',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              _RefreshButton(isRefreshing: isRefreshing, onRefresh: onRefresh),
            ],
          ),

          const SizedBox(height: 20),

          // Title with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                theme.colorScheme.onSurface,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ).createShader(bounds),
            child: Text(
              'Your Learning\nJourney',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Stats badges row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HistoryBadge(
                icon: Icons.quiz_rounded,
                label: '$count Quizzes',
                color: theme.colorScheme.primary,
              ),
              _HistoryBadge(
                icon: Icons.trending_up_rounded,
                label: 'Track Progress',
                color: Colors.orange,
              ),
              _HistoryBadge(
                icon: Icons.insights_rounded,
                label: 'View Stats',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Badge widget for history header
class _HistoryBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HistoryBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _RefreshButton({required this.isRefreshing, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isRefreshing ? null : onRefresh,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
          ),
          child: isRefreshing
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.refresh_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
        ),
      ),
    );
  }
}

// ==========================================
// STATS SUMMARY (SELECTIVE REBUILD)
// ==========================================

class _StatsSummary extends ConsumerWidget {
  const _StatsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Only rebuild when these specific values change
    final quizzes = ref.watch(quizHistoryProvider.select((s) => s.quizzes));
    if (quizzes.isEmpty) return const SizedBox.shrink();

    final state = ref.watch(quizHistoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.quiz_rounded,
              label: 'Total',
              value: state.totalQuizzes.toString(),
              color: theme.colorScheme.primary,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_up_rounded,
              label: 'Average',
              value: '${state.averageScore.round()}%',
              color: Colors.orange,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.emoji_events_rounded,
              label: 'Best',
              value: '${state.bestScore}%',
              color: Colors.green,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// OPTIMIZED QUIZ CARD
// ==========================================

class _OptimizedQuizCard extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final int index;
  final VoidCallback onTap;

  const _OptimizedQuizCard({
    super.key,
    required this.quiz,
    required this.index,
    required this.onTap,
  });

  @override
  State<_OptimizedQuizCard> createState() => _OptimizedQuizCardState();
}

class _OptimizedQuizCardState extends State<_OptimizedQuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    // Staggered animation (max 6 items)
    final delay = (widget.index.clamp(0, 6) * 50);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pre-compute data once
    final title =
        widget.quiz['quizTitle'] ?? widget.quiz['title'] ?? 'Untitled Quiz';
    final totalQuestions =
        widget.quiz['totalQuestions'] ?? widget.quiz['questionCount'] ?? 0;
    final score = widget.quiz['score'] ?? 0;
    final createdAt = widget.quiz['createdAt'] != null
        ? DateTime.parse(widget.quiz['createdAt'])
        : DateTime.now();

    final double percentage = totalQuestions > 0
        ? (score / totalQuestions)
        : 0.0;

    final (statusColor, statusIcon) = _getStatusStyle(percentage);

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_animation),
        child: RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Score Indicator
                      _ScoreIndicator(
                        percentage: percentage,
                        color: statusColor,
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$score/$totalQuestions',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    timeago.format(
                                      createdAt,
                                      allowFromNow: true,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(statusIcon, size: 18, color: statusColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, IconData) _getStatusStyle(double percentage) {
    if (percentage >= 0.8) return (Colors.green, Icons.emoji_events_rounded);
    if (percentage >= 0.6) return (Colors.teal, Icons.thumb_up_rounded);
    if (percentage >= 0.4) return (Colors.orange, Icons.trending_flat_rounded);
    return (Colors.red, Icons.trending_down_rounded);
  }
}

class _ScoreIndicator extends StatelessWidget {
  final double percentage;
  final Color color;

  const _ScoreIndicator({required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 4.5,
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ERROR STATE
// ==========================================

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// EMPTY STATE
// ==========================================

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartQuiz;

  const _EmptyState({required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(
                      isDark ? 0.4 : 0.5,
                    ),
                    theme.colorScheme.primaryContainer.withOpacity(
                      isDark ? 0.2 : 0.3,
                    ),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Quizzes Yet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Take your first quiz and\ntrack your progress here!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: onStartQuiz,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'Start Your First Quiz',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
