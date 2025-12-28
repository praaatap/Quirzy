import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/core/constants/constant.dart';
import 'package:quirzy/features/flashcards/services/flashcard_cache_service.dart';

class FlashcardService {
  static const _storage = FlutterSecureStorage();

  /// Generate flashcards for a topic
  static Future<Map<String, dynamic>> generateFlashcards(
    String topic, {
    int cardCount = 10,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$kBackendApiUrl/flashcards/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'topic': topic, 'cardCount': cardCount}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final result = jsonDecode(response.body);

      // Cache the newly generated set
      await FlashcardCacheService.addSetToCache(result);

      return result;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to generate flashcards');
    }
  }

  /// Get user's flashcard sets (with cache-first strategy)
  static Future<List<Map<String, dynamic>>> getFlashcardSets({
    bool forceRefresh = false,
  }) async {
    // 1. Try cache first if not forcing refresh
    if (!forceRefresh) {
      final cached = FlashcardCacheService.getCachedFlashcardSets();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('📦 Using ${cached.length} cached flashcard sets');

        // Refresh in background if cache is stale
        if (!FlashcardCacheService.isCacheFresh()) {
          _refreshInBackground();
        }
        return cached;
      }
    }

    // 2. Fetch from network
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$kBackendApiUrl/flashcards/sets'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sets = List<Map<String, dynamic>>.from(data['sets'] ?? []);

      // Cache the results
      await FlashcardCacheService.cacheFlashcardSets(sets);

      return sets;
    } else {
      // On network error, try cache as fallback
      final cached = FlashcardCacheService.getCachedFlashcardSets();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('⚠️ Network error, using cache');
        return cached;
      }
      throw Exception('Failed to fetch flashcard sets');
    }
  }

  /// Background refresh without blocking UI
  static Future<void> _refreshInBackground() async {
    try {
      debugPrint('🔄 Background refresh of flashcard sets...');
      final token = await _storage.read(key: 'token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$kBackendApiUrl/flashcards/sets'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sets = List<Map<String, dynamic>>.from(data['sets'] ?? []);
        await FlashcardCacheService.cacheFlashcardSets(sets);
        debugPrint('✅ Background refresh complete');
      }
    } catch (e) {
      debugPrint('⚠️ Background refresh failed: $e');
    }
  }

  /// Get single flashcard set (with caching)
  static Future<Map<String, dynamic>> getFlashcardSet(int setId) async {
    // Try cache first
    final cached = FlashcardCacheService.getCachedFlashcardSet(setId);
    if (cached != null && cached['cards'] != null) {
      debugPrint('📦 Using cached flashcard set #$setId');
      return cached;
    }

    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$kBackendApiUrl/flashcards/sets/$setId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final result = Map<String, dynamic>.from(jsonDecode(response.body));

      // Cache the full set
      await FlashcardCacheService.cacheFlashcardSet(setId, result);

      return result;
    } else {
      // Try cache as fallback
      if (cached != null) return cached;
      throw Exception('Failed to fetch flashcard set');
    }
  }

  /// Delete flashcard set
  static Future<void> deleteFlashcardSet(int setId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('$kBackendApiUrl/flashcards/sets/$setId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Remove from cache
      await FlashcardCacheService.removeCachedSet(setId);
    } else {
      throw Exception('Failed to delete flashcard set');
    }
  }

  /// Update card study progress
  static Future<void> updateCardProgress(int cardId, bool known) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return; // Silently fail if not authenticated

    try {
      final response = await http.patch(
        Uri.parse('$kBackendApiUrl/flashcards/cards/$cardId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'known': known}),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to update card progress');
      }
    } catch (e) {
      debugPrint('Progress update error: $e');
    }
  }
}
