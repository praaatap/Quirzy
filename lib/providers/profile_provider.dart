// lib/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/utils/appwrite.dart';

class ProfileState {
  final List<models.Document>? quizHistory;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.quizHistory,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    List<models.Document>? quizHistory,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      quizHistory: quizHistory ?? this.quizHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;
  late final Databases _databases;

  ProfileNotifier(this.ref) : super(ProfileState()) {
    final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(APPWRITE_PROJECT_ID);
    _databases = Databases(client);
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Replace with your actual database and collection IDs
      final response = await _databases.listDocuments(
        databaseId: 'YOUR_DATABASE_ID',
        collectionId: 'quiz_history',
        queries: [
          Query.equal('userId', ref.read(authProvider).user?.$id ?? ''),
          Query.orderDesc('date'),
        ],
      );
      
      state = state.copyWith(
        quizHistory: response.documents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});