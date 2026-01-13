import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../flashcards/widgets/flashcard_widgets.dart';
import '../services/profile_service.dart';

// ==========================================
// REDESIGNED HISTORY SCREEN
// Full Dark/Light Theme Support
// ==========================================

/// Provider for ProfileService
final _profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Provider for quiz history
final _quizHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(_profileServiceProvider);
  return await service.getQuizHistory();
});

/// Provider for statistics
final _statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(_profileServiceProvider);
  return await service.getStatistics();
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _userName = 'Quiz Master';
  String? _photoUrl;

  // Static colors
  static const primaryColor = Color(0xFF5B13EC);
  static const primaryLight = Color(0xFFEFE9FD);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read(key: 'user_name');
    final photoUrl = await _storage.read(key: 'user_photo_url');
    if (mounted) {
      setState(() {
        if (name != null) _userName = name;
        _photoUrl = photoUrl;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear History?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete all your quiz history. This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final service = ref.read(_profileServiceProvider);
        await service.clearHistory();
        ref.invalidate(_quizHistoryProvider);
        ref.invalidate(_statisticsProvider);
        _showSnackBar('History cleared');
      } catch (e) {
        _showSnackBar('Failed to clear history', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF171717) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF664C9A);

    final historyAsync = ref.watch(_quizHistoryProvider);
    final statsAsync = ref.watch(_statisticsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_quizHistoryProvider);
            ref.invalidate(_statisticsProvider);
          },
          child:
              CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: _buildAppBar(
                          isDark,
                          surfaceColor,
                          textMain,
                          textSub,
                        ),
                      ),

                      // Hero Section
                      SliverToBoxAdapter(
                        child: _buildHeroSection(textMain, textSub, isDark),
                      ),

                      // Stats Cards
                      SliverToBoxAdapter(
                        child: statsAsync.when(
                          data: (stats) => _buildStatsCards(
                            stats,
                            isDark,
                            surfaceColor,
                            textMain,
                            textSub,
                          ),
                          loading: () => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: List.generate(
                                3,
                                (i) => Expanded(
                                  child:
                                      Container(
                                            margin: EdgeInsets.only(
                                              right: i < 2 ? 12 : 0,
                                            ),
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          )
                                          .animate(onPlay: (c) => c.repeat())
                                          .shimmer(
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox(),
                        ),
                      ),

                      // Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Quizzes',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              if (historyAsync.value?.isNotEmpty == true)
                                GestureDetector(
                                  onTap: _clearHistory,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Clear All',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // History List
                      historyAsync.when(
                        data: (history) => history.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(textMain, textSub),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    return _buildHistoryCard(
                                          history[index],
                                          isDark,
                                          surfaceColor,
                                          textMain,
                                          textSub,
                                        )
                                        .animate(delay: (100 + (index * 50)).ms)
                                        .fade(duration: 300.ms)
                                        .slideX(begin: 0.05, end: 0);
                                  }, childCount: history.length),
                                ),
                              ),
                        loading: () => SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverToBoxAdapter(
                            child: ShimmerPlaceholders.historyList(
                              itemCount: 5,
                            ),
                          ),
                        ),
                        error: (error, _) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'Failed to load history',
                              style: GoogleFonts.plusJakartaSans(
                                color: textSub,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Padding
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 100),
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
      ),
    );
  }

  Widget _buildAppBar(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _photoUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _userName.isNotEmpty
                                    ? _userName[0].toUpperCase()
                                    : 'Q',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'Q',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Your progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color textMain, Color textSub, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                    const TextSpan(text: 'Track Your '),
                    TextSpan(
                      text: 'Progress',
                      style: TextStyle(
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 700.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            'Review your quiz performance and improve',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    Map<String, dynamic> stats,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.quiz_rounded,
              value: '${stats['totalQuizzes'] ?? 0}',
              label: 'Quizzes',
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.percent_rounded,
              value: '${stats['averageScore'] ?? 0}%',
              label: 'Average',
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              value: '${stats['perfectScores'] ?? 0}',
              label: 'Perfect',
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
    required Color surfaceColor,
    required Color textMain,
    required Color textSub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> quiz,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final title = quiz['title'] ?? 'Untitled Quiz';
    final score = quiz['score'] ?? 0;
    final total = quiz['totalQuestions'] ?? 10;
    final percentage = quiz['percentage'] ?? 0;
    final createdAt = quiz['createdAt'] != null
        ? DateTime.tryParse(quiz['createdAt'])
        : null;

    final isPerfect = percentage == 100;
    final isGood = percentage >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score Badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPerfect
                    ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                    : isGood
                    ? [primaryColor, const Color(0xFF9333EA)]
                    : [Colors.grey, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: textSub),
                    const SizedBox(width: 4),
                    Text(
                      '$score/$total correct',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSub,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: textSub),
                    const SizedBox(width: 4),
                    Text(
                      createdAt != null
                          ? timeago.format(createdAt)
                          : 'Recently',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Perfect badge
          if (isPerfect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Perfect',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textMain, Color textSub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Quiz History',
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
              'Complete a quiz to see your results here!',
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
