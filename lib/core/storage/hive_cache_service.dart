import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/isolate_compute.dart';

/// ===========================================
/// HIVE CACHE SERVICE
/// ===========================================
/// Core caching service with in-memory layer and Hive persistence.
/// Uses IsolateCompute for heavy operations.

class HiveCacheService {
  static HiveCacheService? _instance;
  static bool _isInitialized = false;

  // Hive boxes
  static Box? _quizHistoryBox;
  static Box? _userDataBox;
  static Box? _settingsBox;

  // Ultra-fast in-memory cache layer
  static List<Map<String, dynamic>>? _memoryHistoryCache;
  static Map<String, dynamic>? _memoryStatsCache;
  static DateTime? _memoryCacheTime;

  // Pre-computed stats
  static QuizStats? _computedStats;

  // Box names
  static const String _quizHistoryBoxName = 'quiz_history';
  static const String _userDataBoxName = 'user_data';
  static const String _settingsBoxName = 'settings';

  // Cache keys
  static const String _historyKey = 'history_list';
  static const String _historyTimestampKey = 'history_timestamp';
  static const String _userStatsKey = 'user_stats';
  static const String _lastSyncKey = 'last_sync';
  static const String _computedStatsKey = 'computed_stats';

  // Cache duration (in minutes)
  static const int _historyTTL = 60; // 1 hour
  static const int _memoryCacheTTL = 5; // 5 minutes for memory cache

  HiveCacheService._internal();

  /// Initialize Hive and cache service - call once at app startup
  static Future<HiveCacheService> initialize() async {
    if (_instance == null) {
      _instance = HiveCacheService._internal();

      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes in parallel for faster startup
      final results = await Future.wait([
        Hive.openBox(_quizHistoryBoxName),
        Hive.openBox(_userDataBoxName),
        Hive.openBox(_settingsBoxName),
      ]);

      _quizHistoryBox = results[0];
      _userDataBox = results[1];
      _settingsBox = results[2];

      // Pre-load memory cache in background
      _instance!._preloadMemoryCache();

      _isInitialized = true;
      debugPrint('✅ Hive cache initialized with memory layer');
    }
    return _instance!;
  }

  /// Pre-load data into memory cache for instant access
  void _preloadMemoryCache() {
    Future.microtask(() async {
      try {
        final data = _quizHistoryBox?.get(_historyKey) as String?;
        if (data != null) {
          // Use isolate for large data parsing
          _memoryHistoryCache = await IsolateCompute.parseJsonList(data);
          _memoryCacheTime = DateTime.now();

          // Pre-compute stats
          if (_memoryHistoryCache != null) {
            _computedStats = await IsolateCompute.computeQuizStats(
              _memoryHistoryCache!,
            );
          }
          debugPrint('📦 Memory cache preloaded');
        }
      } catch (e) {
        debugPrint('⚠️ Memory preload failed: $e');
      }
    });
  }

  /// Get singleton instance (must call initialize first)
  static HiveCacheService get instance {
    if (_instance == null || !_isInitialized) {
      throw Exception(
        'HiveCacheService not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _isInitialized;

  /// Get pre-computed stats (instant, no calculation)
  QuizStats? getComputedStats() => _computedStats;

  // ==========================================
  // QUIZ HISTORY CACHE
  // ==========================================

  /// Save quiz history with isolate-based encoding
  Future<void> saveQuizHistory(List<Map<String, dynamic>> history) async {
    try {
      // Update memory cache immediately (instant UI update)
      _memoryHistoryCache = history;
      _memoryCacheTime = DateTime.now();

      // Compute stats in isolate
      _computedStats = await IsolateCompute.computeQuizStats(history);

      // Encode and save in background
      final encoded = await IsolateCompute.encodeJsonList(history);
      await _quizHistoryBox?.put(_historyKey, encoded);
      await _quizHistoryBox?.put(
        _historyTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Save computed stats for quick access
      await _quizHistoryBox?.put(_computedStatsKey, _computedStats?.toJson());

      debugPrint('📦 Saved ${history.length} quizzes (isolate-encoded)');
    } catch (e) {
      debugPrint('⚠️ Failed to save quiz history: $e');
    }
  }

  /// Get cached quiz history - memory first, then Hive
  List<Map<String, dynamic>>? getQuizHistory() {
    try {
      // 1. Check memory cache first (instant)
      if (_memoryHistoryCache != null && _memoryCacheTime != null) {
        final age = DateTime.now().difference(_memoryCacheTime!).inMinutes;
        if (age < _memoryCacheTTL) {
          debugPrint(
            '⚡ Returned from memory cache (${_memoryHistoryCache!.length} items)',
          );
          return _memoryHistoryCache;
        }
      }

      // 2. Fall back to Hive
      final data = _quizHistoryBox?.get(_historyKey) as String?;
      if (data == null) return null;

      // Check TTL
      final timestamp = _quizHistoryBox?.get(_historyTimestampKey) as int?;
      if (timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedTime).inMinutes > _historyTTL) {
          debugPrint('⏰ Quiz history cache expired');
          return null;
        }
      }

      // Parse synchronously for small data
      final List<dynamic> decoded = jsonDecode(data);
      final result = decoded.map((e) => Map<String, dynamic>.from(e)).toList();

      // Update memory cache
      _memoryHistoryCache = result;
      _memoryCacheTime = DateTime.now();

      debugPrint('✅ Loaded ${decoded.length} quizzes from Hive');
      return result;
    } catch (e) {
      debugPrint('⚠️ Failed to read quiz history: $e');
      return null;
    }
  }

  /// Async version for large datasets
  Future<List<Map<String, dynamic>>?> getQuizHistoryAsync() async {
    try {
      // Check memory first
      if (_memoryHistoryCache != null && _memoryCacheTime != null) {
        if (DateTime.now().difference(_memoryCacheTime!).inMinutes <
            _memoryCacheTTL) {
          return _memoryHistoryCache;
        }
      }

      final data = _quizHistoryBox?.get(_historyKey) as String?;
      if (data == null) return null;

      // Parse in isolate
      final result = await IsolateCompute.parseJsonList(data);
      _memoryHistoryCache = result;
      _memoryCacheTime = DateTime.now();

      return result;
    } catch (e) {
      debugPrint('⚠️ Failed to read quiz history async: $e');
      return null;
    }
  }

  /// Add single quiz to history (optimistic update)
  Future<void> addQuizToHistory(Map<String, dynamic> quiz) async {
    // Instant memory update
    _memoryHistoryCache = [quiz, ...(_memoryHistoryCache ?? [])];
    _memoryCacheTime = DateTime.now();

    // Recompute stats
    if (_memoryHistoryCache != null) {
      _computedStats = await IsolateCompute.computeQuizStats(
        _memoryHistoryCache!,
      );
    }

    // Persist in background (non-blocking)
    Future.microtask(() async {
      await saveQuizHistory(_memoryHistoryCache!);
    });
  }

  /// Clear quiz history cache
  Future<void> clearQuizHistory() async {
    _memoryHistoryCache = null;
    _memoryCacheTime = null;
    _computedStats = null;
    await _quizHistoryBox?.delete(_historyKey);
    await _quizHistoryBox?.delete(_historyTimestampKey);
    await _quizHistoryBox?.delete(_computedStatsKey);
    debugPrint('🗑️ Quiz history cleared');
  }

  // ==========================================
  // USER STATS CACHE
  // ==========================================

  Future<void> saveUserStats(Map<String, dynamic> stats) async {
    try {
      _memoryStatsCache = stats;
      await _userDataBox?.put(_userStatsKey, jsonEncode(stats));
      debugPrint('📦 User stats saved');
    } catch (e) {
      debugPrint('⚠️ Failed to save user stats: $e');
    }
  }

  Map<String, dynamic>? getUserStats() {
    if (_memoryStatsCache != null) return _memoryStatsCache;

    try {
      final data = _userDataBox?.get(_userStatsKey) as String?;
      if (data == null) return null;
      _memoryStatsCache = Map<String, dynamic>.from(jsonDecode(data));
      return _memoryStatsCache;
    } catch (e) {
      debugPrint('⚠️ Failed to read user stats: $e');
      return null;
    }
  }

  // ==========================================
  // SYNC TRACKING
  // ==========================================

  Future<void> updateLastSync() async {
    await _settingsBox?.put(
      _lastSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime? getLastSync() {
    final timestamp = _settingsBox?.get(_lastSyncKey) as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool shouldRefresh({int thresholdMinutes = 15}) {
    final lastSync = getLastSync();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inMinutes > thresholdMinutes;
  }

  // ==========================================
  // SETTINGS CACHE
  // ==========================================

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox?.get(key) as T?;
  }

  // ==========================================
  // CACHE MANAGEMENT
  // ==========================================

  Future<void> clearAllCache() async {
    _memoryHistoryCache = null;
    _memoryStatsCache = null;
    _memoryCacheTime = null;
    _computedStats = null;
    await _quizHistoryBox?.clear();
    await _userDataBox?.clear();
    debugPrint('🗑️ All cache cleared');
  }

  bool hasOfflineData() {
    return _memoryHistoryCache != null ||
        _quizHistoryBox?.get(_historyKey) != null;
  }

  /// Invalidate memory cache (force reload from Hive)
  void invalidateMemoryCache() {
    _memoryHistoryCache = null;
    _memoryStatsCache = null;
    _memoryCacheTime = null;
  }

  static Future<void> close() async {
    _memoryHistoryCache = null;
    _memoryStatsCache = null;
    _computedStats = null;
    await _quizHistoryBox?.close();
    await _userDataBox?.close();
    await _settingsBox?.close();
    _isInitialized = false;
    debugPrint('📦 Hive boxes closed');
  }
}
