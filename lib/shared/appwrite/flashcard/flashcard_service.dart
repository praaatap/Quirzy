import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../appwrite_client.dart';

/// Flashcard Service - Complete flashcard operations
class FlashcardService {
  static FlashcardService? _instance;
  final Databases _db = AppwriteClient.instance.databases;

  factory FlashcardService() {
    _instance ??= FlashcardService._internal();
    return _instance!;
  }

  FlashcardService._internal();

  /// Create flashcard set
  Future<String> createFlashcardSet({
    required String userId,
    required String title,
    required String topic,
    required List<Map<String, dynamic>> cards,
    bool isPublic = false,
  }) async {
    try {
      final result = await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.flashcardsCollection,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'title': title,
          'topic': topic,
          'cards': cards,
          'cardCount': cards.length,
          'isPublic': isPublic,
          'studyCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return result.$id;
    } catch (e) {
      debugPrint('FlashcardService: Create set error: $e');
      rethrow;
    }
  }

  /// Get user's flashcard sets
  Future<List<Map<String, dynamic>>> getUserFlashcardSets({required String userId}) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.flashcardsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
        ],
      );
      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      debugPrint('FlashcardService: Get sets error: $e');
      return [];
    }
  }

  /// Update flashcard set
  Future<void> updateFlashcardSet({
    required String setId,
    String? title,
    List<Map<String, dynamic>>? cards,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (cards != null) {
        data['cards'] = cards;
        data['cardCount'] = cards.length;
      }

      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.flashcardsCollection,
        documentId: setId,
        data: data,
      );
    } catch (e) {
      debugPrint('FlashcardService: Update set error: $e');
      rethrow;
    }
  }

  /// Delete flashcard set
  Future<void> deleteFlashcardSet({required String setId}) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.flashcardsCollection,
        documentId: setId,
      );
    } catch (e) {
      debugPrint('FlashcardService: Delete set error: $e');
      rethrow;
    }
  }
}
