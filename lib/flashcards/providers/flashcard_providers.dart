import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/flashcard_service.dart';

/// Provider for FlashcardService singleton
final flashcardServiceProvider = Provider<FlashcardService>((ref) {
  return FlashcardService();
});

/// Provider for user's flashcard sets
final flashcardSetsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(flashcardServiceProvider);
  return service.getMyFlashcardSets();
});

/// Provider for a single flashcard set by ID
final flashcardSetProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, setId) async {
      final service = ref.watch(flashcardServiceProvider);
      return service.getFlashcardSetById(setId);
    });
