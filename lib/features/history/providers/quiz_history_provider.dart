import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';
import 'package:quirzy/core/storage/hive_cache_service.dart';

/// ===========================================
/// HIGH-PERFORMANCE QUIZ HISTORY STATE
/// ===========================================
/// Features:
/// - Immutable state with pre-computed values
/// - Lazy computation with memoization
/// - Efficient copyWith for minimal allocations

class QuizHistoryState {
  final List<Map<String, dynamic>> quizzes;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool isFromCache;
  final DateTime? lastUpdated;

  // Pre-computed values (memoized)
  final int? _cachedTotalQuizzes;
  final double? _cachedAverageScore;
  final int? _cachedBestScore;
  final int? _cachedTotalCorrect;
  final int? _cachedTotalQuestions;

  const QuizHistoryState({
    this.quizzes = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.isFromCache = false,
    this.lastUpdated,
    int? cachedTotalQuizzes,
    double? cachedAverageScore,
    int? cachedBestScore,
    int? cachedTotalCorrect,
    int? cachedTotalQuestions,
  }) : _cachedTotalQuizzes = cachedTotalQuizzes,
       _cachedAverageScore = cachedAverageScore,
       _cachedBestScore = cachedBestScore,
       _cachedTotalCorrect = cachedTotalCorrect,
       _cachedTotalQuestions = cachedTotalQuestions;

  QuizHistoryState copyWith({
    List<Map<String, dynamic>>? quizzes,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? isFromCache,
    DateTime? lastUpdated,
    bool clearError = false,
    // Pre-computed stats
    int? cachedTotalQuizzes,
    double? cachedAverageScore,
    int? cachedBestScore,
    int? cachedTotalCorrect,
    int? cachedTotalQuestions,
  }) {
    return QuizHistoryState(
      quizzes: quizzes ?? this.quizzes,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      isFromCache: isFromCache ?? this.isFromCache,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      // Invalidate cache if quizzes changed
      cachedTotalQuizzes: quizzes != null
          ? null
          : (cachedTotalQuizzes ?? _cachedTotalQuizzes),
      cachedAverageScore: quizzes != null
          ? null
          : (cachedAverageScore ?? _cachedAverageScore),
      cachedBestScore: quizzes != null
          ? null
          : (cachedBestScore ?? _cachedBestScore),
      cachedTotalCorrect: quizzes != null
          ? null
          : (cachedTotalCorrect ?? _cachedTotalCorrect),
      cachedTotalQuestions: quizzes != null
          ? null
          : (cachedTotalQuestions ?? _cachedTotalQuestions),
    );
  }

  // ==========================================
  // LAZY COMPUTED PROPERTIES (MEMOIZED)
  // ==========================================

  int get totalQuizzes => _cachedTotalQuizzes ?? quizzes.length;

  double get averageScore {
    final cached = _cachedAverageScore;
    if (cached != null) return cached;
    if (quizzes.isEmpty) return 0;

    double totalPercentage = 0;
    for (final quiz in quizzes) {
      final score = quiz['score'] ?? 0;
      final total = quiz['totalQuestions'] ?? quiz['questionCount'] ?? 1;
      totalPercentage += (score / total) * 100;
    }
    return totalPercentage / quizzes.length;
  }

  int get bestScore {
    final cached = _cachedBestScore;
    if (cached != null) return cached;
    if (quizzes.isEmpty) return 0;

    int best = 0;
    for (final quiz in quizzes) {
      final score = quiz['score'] ?? 0;
      final total = quiz['totalQuestions'] ?? quiz['questionCount'] ?? 1;
      final percentage = ((score / total) * 100).round();
      if (percentage > best) best = percentage;
    }
    return best;
  }

  int get totalCorrectAnswers {
    final cached = _cachedTotalCorrect;
    if (cached != null) return cached;
    int total = 0;
    for (final quiz in quizzes) {
      total += (quiz['score'] as int? ?? 0);
    }
    return total;
  }

  int get totalQuestions {
    final cached = _cachedTotalQuestions;
    if (cached != null) return cached;
    int total = 0;
    for (final quiz in quizzes) {
      total +=
          (quiz['totalQuestions'] as int? ??
          quiz['questionCount'] as int? ??
          0);
    }
    return total;
  }

  /// Create state with pre-computed stats (faster subsequent access)
  QuizHistoryState withComputedStats() {
    return copyWith(
      cachedTotalQuizzes: quizzes.length,
      cachedAverageScore: averageScore,
      cachedBestScore: bestScore,
      cachedTotalCorrect: totalCorrectAnswers,
      cachedTotalQuestions: totalQuestions,
    );
  }
}

/// ===========================================
/// OPTIMIZED QUIZ HISTORY NOTIFIER
/// ===========================================
/// Performance optimizations:
/// - Debounced refresh to prevent spam
/// - Throttled background sync
/// - Smart state updates (only when changed)
/// - Isolate-based data processing via cache service

class QuizHistoryNotifier extends Notifier<QuizHistoryState> {
  Timer? _debounceTimer;
  bool _isBackgroundRefreshing = false;

  // Throttle settings
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  static const Duration _minRefreshInterval = Duration(seconds: 30);
  DateTime? _lastRefreshTime;

  @override
  QuizHistoryState build() {
    // Cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Defer the initial load to avoid circular dependency
    Future.microtask(() => loadHistory());
    return const QuizHistoryState();
  }

  QuizService get _quizService => ref.read(quizServiceProvider);

  /// Load history with cache-first strategy and isolate support
  Future<void> loadHistory({bool forceRefresh = false}) async {
    try {
      final cacheService = HiveCacheService.instance;

      // 1. Check memory/Hive cache first (instant)
      if (!forceRefresh) {
        // Try async version for large datasets (uses isolates)
        final cachedHistory =
            await cacheService.getQuizHistoryAsync() ??
            cacheService.getQuizHistory();

        if (cachedHistory != null && cachedHistory.isNotEmpty) {
          // Get pre-computed stats if available
          final computedStats = cacheService.getComputedStats();

          state = QuizHistoryState(
            quizzes: cachedHistory,
            isLoading: false,
            isFromCache: true,
            lastUpdated: cacheService.getLastSync(),
            cachedTotalQuizzes: computedStats?.totalQuizzes,
            cachedAverageScore: computedStats?.avgPercentage.toDouble(),
            cachedBestScore: computedStats?.bestPercentage,
            cachedTotalCorrect: computedStats?.totalCorrect,
            cachedTotalQuestions: computedStats?.totalQuestions,
          );

          debugPrint('📦 Loaded ${cachedHistory.length} quizzes from cache');

          // Background refresh if stale
          if (cacheService.shouldRefresh()) {
            _scheduleBackgroundRefresh();
          }
          return;
        }
      }

      // 2. Show loading only if no data
      if (state.quizzes.isEmpty) {
        state = state.copyWith(isLoading: true);
      }

      // 3. Fetch from network
      final history = await _quizService.getQuizHistory();

      // 4. Save to cache (uses isolates for encoding)
      await cacheService.saveQuizHistory(history);
      await cacheService.updateLastSync();

      // 5. Update state with pre-computed stats
      final computedStats = cacheService.getComputedStats();
      state = QuizHistoryState(
        quizzes: history,
        isLoading: false,
        isFromCache: false,
        lastUpdated: DateTime.now(),
        cachedTotalQuizzes: computedStats?.totalQuizzes,
        cachedAverageScore: computedStats?.avgPercentage.toDouble(),
        cachedBestScore: computedStats?.bestPercentage,
        cachedTotalCorrect: computedStats?.totalCorrect,
        cachedTotalQuestions: computedStats?.totalQuestions,
      );

      _lastRefreshTime = DateTime.now();
      debugPrint('✅ Loaded ${history.length} quizzes from network');
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      _handleLoadError(e);
    }
  }

  /// Handle load errors with cache fallback
  void _handleLoadError(dynamic error) {
    final cacheService = HiveCacheService.instance;
    final cachedHistory = cacheService.getQuizHistory();

    if (cachedHistory != null && cachedHistory.isNotEmpty) {
      final computedStats = cacheService.getComputedStats();
      state = QuizHistoryState(
        quizzes: cachedHistory,
        isLoading: false,
        isFromCache: true,
        error: 'Using cached data. ${error.toString()}',
        cachedTotalQuizzes: computedStats?.totalQuizzes,
        cachedAverageScore: computedStats?.avgPercentage.toDouble(),
        cachedBestScore: computedStats?.bestPercentage,
      );
    } else {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// Schedule background refresh (throttled)
  void _scheduleBackgroundRefresh() {
    if (_isBackgroundRefreshing) return;

    Future.microtask(() => _refreshInBackground());
  }

  /// Background refresh without blocking UI
  Future<void> _refreshInBackground() async {
    if (_isBackgroundRefreshing) return;

    // Throttle check
    if (_lastRefreshTime != null) {
      final elapsed = DateTime.now().difference(_lastRefreshTime!);
      if (elapsed < _minRefreshInterval) {
        debugPrint('⏱️ Background refresh throttled');
        return;
      }
    }

    _isBackgroundRefreshing = true;

    try {
      debugPrint('🔄 Background refresh started');
      final cacheService = HiveCacheService.instance;
      final history = await _quizService.getQuizHistory();

      // Only update if data actually changed
      if (!_listsEqual(history, state.quizzes)) {
        await cacheService.saveQuizHistory(history);
        await cacheService.updateLastSync();

        final computedStats = cacheService.getComputedStats();
        state = state.copyWith(
          quizzes: history,
          isFromCache: false,
          lastUpdated: DateTime.now(),
          clearError: true,
          cachedTotalQuizzes: computedStats?.totalQuizzes,
          cachedAverageScore: computedStats?.avgPercentage.toDouble(),
          cachedBestScore: computedStats?.bestPercentage,
        );
        debugPrint('✅ Background refresh: data updated');
      } else {
        debugPrint('✅ Background refresh: no changes');
      }

      _lastRefreshTime = DateTime.now();
    } catch (e) {
      debugPrint('⚠️ Background refresh failed: $e');
    } finally {
      _isBackgroundRefreshing = false;
    }
  }

  /// Compare two lists efficiently
  bool _listsEqual(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;

    // Quick check: compare first and last item IDs
    final aFirstId = a.first['_id'] ?? a.first['id'];
    final bFirstId = b.first['_id'] ?? b.first['id'];
    if (aFirstId != bFirstId) return false;

    if (a.length > 1) {
      final aLastId = a.last['_id'] ?? a.last['id'];
      final bLastId = b.last['_id'] ?? b.last['id'];
      if (aLastId != bLastId) return false;
    }

    return true;
  }

  /// Refresh with debounce (prevents rapid refresh spam)
  Future<void> refresh() async {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDelay, () async {
      state = state.copyWith(isRefreshing: true);
      await loadHistory(forceRefresh: true);
      state = state.copyWith(isRefreshing: false);
    });
  }

  /// Immediate refresh (bypass debounce)
  Future<void> refreshNow() async {
    state = state.copyWith(isRefreshing: true);
    await loadHistory(forceRefresh: true);
    state = state.copyWith(isRefreshing: false);
  }

  /// Add a quiz result with optimistic update
  void addQuizResult(Map<String, dynamic> result) {
    final cacheService = HiveCacheService.instance;

    // Optimistic update (instant UI)
    final updatedList = [result, ...state.quizzes];
    state = state
        .copyWith(quizzes: updatedList, lastUpdated: DateTime.now())
        .withComputedStats(); // Recompute stats

    // Persist in background
    cacheService.addQuizToHistory(result);
  }

  /// Clear cache and reload
  Future<void> clearAndReload() async {
    final cacheService = HiveCacheService.instance;
    await cacheService.clearQuizHistory();
    state = const QuizHistoryState();
    await loadHistory(forceRefresh: true);
  }

  /// Preload data for faster access
  Future<void> preload() async {
    if (state.quizzes.isNotEmpty) return;
    await loadHistory();
  }
}

/// The provider
final quizHistoryProvider =
    NotifierProvider<QuizHistoryNotifier, QuizHistoryState>(
      QuizHistoryNotifier.new,
    );
