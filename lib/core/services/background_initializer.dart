import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

/// Background Initializer - Runs heavy initialization tasks in isolates
/// Prevents animation jank during splash screen to home transition
class BackgroundInitializer {
  static final BackgroundInitializer _instance =
      BackgroundInitializer._internal();
  factory BackgroundInitializer() => _instance;
  BackgroundInitializer._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Pre-warm caches and services in background
  /// Call this early, runs non-blocking
  static Future<void> preWarmInBackground() async {
    try {
      // Use compute for heavy work to prevent jank
      await compute(_backgroundPreWarm, null);
    } catch (e) {
      debugPrint('⚠️ Background pre-warm failed: $e');
    }
  }

  /// Heavy pre-warming work - runs in isolate
  static Future<void> _backgroundPreWarm(void _) async {
    // Note: Cannot access Flutter bindings in isolates
    // Just simulate pre-computation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Initialize services that must run on main thread but are deferrable
  Future<void> initializeDeferredServices() async {
    if (_isInitialized) return;

    debugPrint('🚀 Starting deferred initialization...');

    // Use microtasks to not block UI
    await Future.microtask(() async {
      // These will run in gaps between frames
      try {
        // Open commonly used Hive boxes ahead of time
        await _preOpenHiveBoxes();
      } catch (e) {
        debugPrint('⚠️ Hive pre-open failed: $e');
      }
    });

    _isInitialized = true;
    debugPrint('✅ Deferred initialization complete');
  }

  /// Pre-open Hive boxes for faster access later
  static Future<void> _preOpenHiveBoxes() async {
    final boxNames = [
      'offline_quizzes',
      'achievements',
      'spaced_repetition',
      'notification_tracking',
      'app_review',
      'daily_challenges',
    ];

    for (final name in boxNames) {
      try {
        if (!Hive.isBoxOpen(name)) {
          await Hive.openBox(name);
        }
      } catch (e) {
        debugPrint('⚠️ Could not pre-open $name: $e');
      }
    }
  }

  /// Schedule post-frame callback - runs after current frame completes
  static void scheduleAfterFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  /// Schedule idle callback - runs when there's idle time
  static void scheduleWhenIdle(VoidCallback callback) {
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      Future.microtask(callback);
    });
  }
}

/// Mixin for screens that need smooth entry animations
/// Use this on HomeScreen or other screens after splash
mixin SmoothEntryMixin<T extends StatefulWidget> on State<T> {
  bool _entryAnimationComplete = false;
  bool get entryAnimationComplete => _entryAnimationComplete;

  /// Call this in initState to defer heavy work
  void initWithSmoothEntry({
    Duration delay = const Duration(milliseconds: 300),
    required VoidCallback onAnimationComplete,
  }) {
    // Let the entry animation complete first
    Future.delayed(delay, () {
      if (mounted) {
        setState(() => _entryAnimationComplete = true);
        onAnimationComplete();
      }
    });
  }

  /// Wrap heavy widgets with this to defer their build
  Widget deferBuild({
    required Widget child,
    Widget placeholder = const SizedBox.shrink(),
  }) {
    return _entryAnimationComplete ? child : placeholder;
  }
}

/// Lightweight placeholder widgets for deferred loading
class DeferredWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Widget placeholder;

  const DeferredWidget({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.placeholder = const SizedBox.shrink(),
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _showChild = false;

  @override
  void initState() {
    super.initState();
    // Schedule for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _showChild = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showChild ? widget.child : widget.placeholder;
  }
}

/// Frame budget tracker - helps ensure smooth 60fps
class FrameBudgetTracker {
  static const int targetFrameTimeMs = 16; // 60fps
  static const int safeFrameBudgetMs = 8; // Leave room for rendering

  /// Check if we have time left in current frame
  static bool hasTimeBudget(Stopwatch stopwatch) {
    return stopwatch.elapsedMilliseconds < safeFrameBudgetMs;
  }

  /// Yield to let a frame render if we've used too much time
  static Future<void> yieldIfNeeded(Stopwatch stopwatch) async {
    if (!hasTimeBudget(stopwatch)) {
      await Future.delayed(Duration.zero);
      stopwatch.reset();
      stopwatch.start();
    }
  }
}
