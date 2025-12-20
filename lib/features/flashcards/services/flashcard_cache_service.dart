import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local cache service for flashcards using Hive
class FlashcardCacheService {
  static const String _boxName = 'flashcard_cache';
  static const String _setsKey = 'flashcard_sets';
  static const String _lastSyncKey = 'flashcards_last_sync';

  static Box? _box;

  /// Initialize Hive box
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox(_boxName);
      } else {
        _box = Hive.box(_boxName);
      }
      debugPrint('📦 FlashcardCacheService initialized');
    } catch (e) {
      debugPrint('❌ Failed to init flashcard cache: $e');
    }
  }

  /// Cache flashcard sets locally
  static Future<void> cacheFlashcardSets(
    List<Map<String, dynamic>> sets,
  ) async {
    try {
      await _ensureBoxOpen();
      final jsonData = jsonEncode(sets);
      await _box?.put(_setsKey, jsonData);
      await _box?.put(_lastSyncKey, DateTime.now().toIso8601String());
      debugPrint('💾 Cached ${sets.length} flashcard sets');
    } catch (e) {
      debugPrint('❌ Cache write error: $e');
    }
  }

  /// Get cached flashcard sets
  static List<Map<String, dynamic>>? getCachedFlashcardSets() {
    try {
      final jsonData = _box?.get(_setsKey);
      if (jsonData == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonData);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  /// Cache a single flashcard set with its cards
  static Future<void> cacheFlashcardSet(
    int setId,
    Map<String, dynamic> setData,
  ) async {
    try {
      await _ensureBoxOpen();
      final key = 'set_$setId';
      await _box?.put(key, jsonEncode(setData));
      debugPrint('💾 Cached flashcard set #$setId');
    } catch (e) {
      debugPrint('❌ Cache set error: $e');
    }
  }

  /// Get a cached flashcard set
  static Map<String, dynamic>? getCachedFlashcardSet(int setId) {
    try {
      final key = 'set_$setId';
      final jsonData = _box?.get(key);
      if (jsonData == null) return null;

      return Map<String, dynamic>.from(jsonDecode(jsonData));
    } catch (e) {
      debugPrint('❌ Cache get set error: $e');
      return null;
    }
  }

  /// Remove a cached flashcard set
  static Future<void> removeCachedSet(int setId) async {
    try {
      await _ensureBoxOpen();
      await _box?.delete('set_$setId');

      // Also update the sets list
      final sets = getCachedFlashcardSets();
      if (sets != null) {
        sets.removeWhere((s) => s['id'] == setId);
        await cacheFlashcardSets(sets);
      }
    } catch (e) {
      debugPrint('❌ Cache remove error: $e');
    }
  }

  /// Add a new set to cache
  static Future<void> addSetToCache(Map<String, dynamic> newSet) async {
    try {
      await _ensureBoxOpen();
      final sets = getCachedFlashcardSets() ?? [];
      sets.insert(0, newSet);
      await cacheFlashcardSets(sets);

      if (newSet['id'] != null) {
        await cacheFlashcardSet(newSet['id'], newSet);
      }
    } catch (e) {
      debugPrint('❌ Cache add error: $e');
    }
  }

  /// Check if cache is fresh (less than 5 minutes old)
  static bool isCacheFresh() {
    try {
      final lastSync = _box?.get(_lastSyncKey);
      if (lastSync == null) return false;

      final syncTime = DateTime.parse(lastSync);
      final age = DateTime.now().difference(syncTime);
      return age.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  /// Clear all flashcard cache
  static Future<void> clearCache() async {
    try {
      await _ensureBoxOpen();
      await _box?.clear();
      debugPrint('🗑️ Flashcard cache cleared');
    } catch (e) {
      debugPrint('❌ Cache clear error: $e');
    }
  }

  static Future<void> _ensureBoxOpen() async {
    if (_box == null || !(_box?.isOpen ?? false)) {
      await init();
    }
  }
}
