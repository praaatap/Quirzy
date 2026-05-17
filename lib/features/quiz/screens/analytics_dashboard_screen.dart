import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/appwrite/quiz/quiz_service.dart';
import '../../../config/theme_config.dart';
import 'quiz_generation_loading_screen.dart';
import 'start_quiz_screen.dart';
import '../providers/quiz_providers.dart';

/// Analytics Dashboard - Shows user's learning progress and insights
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  final QuizService _quizService = QuizService();
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _weakAreas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _practiceWeakArea(String topic) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizGenerationLoadingScreen()),
    );

    try {
      final quizService = ref.read(quizServiceProvider);
      final result = await quizService.generateQuiz(
        topic: topic,
        questionCount: 10,
        difficulty: 'medium',
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StartQuizScreen(
              quizId: result['quizId']?.toString() ?? '',
              quizTitle: result['title']?.toString() ?? topic,
              questions: List<Map<String, dynamic>>.from(result['questions'] ?? []),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate quiz: $e')),
        );
      }
    }
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final userId = await _storage.read(key: 'user_id') ?? '';
      if (userId.isEmpty) return;

      final stats = await _quizService.getQuizStatistics(userId: userId);
      final weakAreas = await _quizService.getWeakAreas(userId: userId);

      if (mounted) {
        setState(() {
          _stats = stats;
          _weakAreas = weakAreas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? ThemeConfig.backgroundDark : ThemeConfig.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
          ),
        ),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats Overview Cards
                  _buildStatsCards(isDark),
                  const SizedBox(height: 24),

                  // Performance Trend Chart
                  _buildPerformanceChart(isDark),
                  const SizedBox(height: 24),

                  // Topic Breakdown
                  _buildTopicBreakdown(isDark),
                  const SizedBox(height: 24),

                  // Weak Areas
                  if (_weakAreas.isNotEmpty) ...[
                    _buildWeakAreas(isDark),
                    const SizedBox(height: 24),
                  ],

                  // Study Recommendations
                  _buildRecommendations(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final totalQuizzes = _stats['totalQuizzes'] ?? 0;
    final averageScore = _stats['averageScore'] ?? 0.0;
    final perfectScores = _stats['perfectScores'] ?? 0;
    final totalXP = _stats['totalXP'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(Icons.quiz, totalQuizzes.toString(), 'Quizzes', ThemeConfig.primaryColor, isDark),
        _buildStatCard(Icons.percent, '${averageScore.toStringAsFixed(1)}%', 'Average', ThemeConfig.successColor, isDark),
        _buildStatCard(Icons.star, perfectScores.toString(), 'Perfect', ThemeConfig.warningColor, isDark),
        _buildStatCard(Icons.stars, '$totalXP', 'Total XP', ThemeConfig.secondaryColor, isDark),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trend',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 60),
                      const FlSpot(1, 65),
                      const FlSpot(2, 70),
                      const FlSpot(3, 68),
                      const FlSpot(4, 75),
                      const FlSpot(5, 80),
                      const FlSpot(6, 82),
                    ],
                    isCurved: true,
                    color: ThemeConfig.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ThemeConfig.primaryColor.withOpacity(0.3),
                          ThemeConfig.primaryColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildTopicBreakdown(bool isDark) {
    final topicBreakdown = _stats['topicBreakdown'] as Map<String, dynamic>? ?? {};

    if (topicBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topic Breakdown',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          ...topicBreakdown.entries.take(5).map((entry) {
            final topic = entry.key;
            final score = (entry.value as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topic,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: score >= 80
                              ? ThemeConfig.successColor
                              : score >= 60
                                  ? ThemeConfig.warningColor
                                  : ThemeConfig.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        score >= 80
                            ? ThemeConfig.successColor
                            : score >= 60
                                ? ThemeConfig.warningColor
                                : ThemeConfig.errorColor,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildWeakAreas(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_down, color: ThemeConfig.errorColor),
              const SizedBox(width: 8),
              Text(
                'Weak Areas - Practice Now!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._weakAreas.take(3).map((area) {
            final topic = area['topic'] as String;
            final score = (area['averageScore'] as num).toDouble();
            final attempts = area['attempts'] as int;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeConfig.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${score.toStringAsFixed(0)}% avg • $attempts attempts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _practiceWeakArea(topic),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Practice',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecommendations(bool isDark) {
    final recommendations = <String>[];

    if (_weakAreas.isNotEmpty) {
      recommendations.add('🎯 Focus on: ${_weakAreas.first['topic']}');
    }

    final totalQuizzes = _stats['totalQuizzes'] ?? 0;
    if (totalQuizzes < 5) {
      recommendations.add('📚 Take more quizzes to get better insights');
    }

    recommendations.add('🔥 Maintain your daily streak for bonus XP');
    recommendations.add('⚡ Try Quick Practice for rapid improvement');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor.withOpacity(0.1),
            ThemeConfig.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Study Tips',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  rec,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                  ),
                ),
              )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
