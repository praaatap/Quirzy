import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/models/user_models.dart';
import 'package:quirzy/service/api_service.dart';

// ==================== STATE CLASS ====================

class VersusState {
  final List<User> users;
  final bool isLoading;
  final String? error;
  final String? selectedUserId;

  const VersusState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.selectedUserId,
  });

  VersusState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
    String? selectedUserId,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return VersusState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedUserId: clearSelection ? null : (selectedUserId ?? this.selectedUserId),
    );
  }

  @override
  String toString() {
    return 'VersusState(users: ${users.length}, isLoading: $isLoading, error: $error, selectedUserId: $selectedUserId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VersusState &&
        other.users == users &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.selectedUserId == selectedUserId;
  }

  @override
  int get hashCode {
    return users.hashCode ^
        isLoading.hashCode ^
        error.hashCode ^
        selectedUserId.hashCode;
  }
}

// ==================== STATE NOTIFIER ====================

class VersusNotifier extends StateNotifier<VersusState> {
  final Ref ref;

  VersusNotifier(this.ref) : super(const VersusState());

  /// Search users by name or email
  /// Minimum 3 characters required
  Future<void> searchUsers(String query) async {
    // Clear users if query is too short
    if (query.isEmpty || query.length < 3) {
      state = state.copyWith(
        users: [],
        clearError: true,
        clearSelection: true,
      );
      debugPrint('🔍 Query too short, cleared users');
      return;
    }

    // Set loading state
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      debugPrint('🔍 Searching for: "$query"');
      
      // Call API
      final response = await ApiService.searchUsers(query);
      
      debugPrint('✅ API Response received');
      debugPrint('   Response keys: ${response.keys}');
      
      // Parse users from response
      final List<dynamic> usersJson = response['users'] as List? ?? [];
      
      debugPrint('   Users JSON length: ${usersJson.length}');
      
      // Convert to User objects
      final users = usersJson
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('✅ Parsed ${users.length} users:');
      for (var user in users) {
        debugPrint('   - ID: ${user.id}, Username: ${user.username}, Email: ${user.email}');
      }
      
      // Update state with results
      state = state.copyWith(
        users: users,
        isLoading: false,
        clearError: true,
      );
      
      debugPrint('✅ State updated successfully');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Search error: $e');
      debugPrint('   Stack trace: $stackTrace');
      
      // Update state with error
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
        users: [],
      );
    }
  }

  /// Select or deselect a user
  void selectUser(String userId) {
    if (state.selectedUserId == userId) {
      // Deselect if already selected
      debugPrint('📌 Deselected user ID: $userId');
      state = state.copyWith(clearSelection: true);
    } else {
      // Select new user
      debugPrint('📌 Selected user ID: $userId');
      state = state.copyWith(selectedUserId: userId);
    }
  }

  /// Get the currently selected user object
  User? getSelectedUser() {
    if (state.selectedUserId == null) return null;
    
    try {
      return state.users.firstWhere(
        (user) => user.id.toString() == state.selectedUserId,
      );
    } catch (e) {
      debugPrint('⚠️ Selected user not found in list');
      return null;
    }
  }

  /// Send challenge to selected user
  Future<Map<String, dynamic>> sendChallenge({int? quizId}) async {
    if (state.selectedUserId == null) {
      debugPrint('❌ No user selected');
      throw Exception('Please select a user to challenge');
    }

    try {
      final selectedUser = getSelectedUser();
      debugPrint('📤 Sending challenge to: ${selectedUser?.username ?? 'Unknown'}');
      debugPrint('   User ID: ${state.selectedUserId}');
      if (quizId != null) {
        debugPrint('   Quiz ID: $quizId');
      }
      
      // Call API to send challenge
      final result = await ApiService.sendChallenge(
        opponentId: int.parse(state.selectedUserId!),
        quizId: quizId,
      );
      
      debugPrint('✅ Challenge sent successfully');
      debugPrint('   Challenge ID: ${result['challenge']?['id']}');
      debugPrint('   Opponent: ${result['challenge']?['opponentName']}');
      
      // Clear selection and users after successful send
      state = state.copyWith(
        clearSelection: true,
        users: [],
        clearError: true,
      );
      
      debugPrint('✅ State cleared after sending challenge');
      
      return result;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Send challenge error: $e');
      debugPrint('   Stack trace: $stackTrace');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Clear selected user
  void clearSelection() {
    debugPrint('🗑️ Clearing selection');
    state = state.copyWith(clearSelection: true);
  }

  /// Clear all users from list
  void clearUsers() {
    debugPrint('🗑️ Clearing users list');
    state = state.copyWith(
      users: [],
      clearError: true,
      clearSelection: true,
    );
  }

  /// Clear error message
  void clearError() {
    debugPrint('🗑️ Clearing error');
    state = state.copyWith(clearError: true);
  }

  /// Reset to initial state
  void reset() {
    debugPrint('🔄 Resetting versus state');
    state = const VersusState();
  }

  /// Check if a user is selected
  bool get hasSelection => state.selectedUserId != null;

  /// Check if there are search results
  bool get hasResults => state.users.isNotEmpty;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.error != null;
}

// ==================== PROVIDER ====================

final versusProvider = StateNotifierProvider<VersusNotifier, VersusState>((ref) {
  debugPrint('🎮 VersusProvider initialized');
  return VersusNotifier(ref);
});

// ==================== ADDITIONAL PROVIDERS ====================

/// Provider to check if a user is selected
final hasSelectedUserProvider = Provider<bool>((ref) {
  final state = ref.watch(versusProvider);
  return state.selectedUserId != null;
});

/// Provider to get selected user
final selectedUserProvider = Provider<User?>((ref) {
  final notifier = ref.read(versusProvider.notifier);
  return notifier.getSelectedUser();
});

/// Provider to get search results count
final searchResultsCountProvider = Provider<int>((ref) {
  final state = ref.watch(versusProvider);
  return state.users.length;
});

/// Provider to check if search is active
final isSearchingProvider = Provider<bool>((ref) {
  final state = ref.watch(versusProvider);
  return state.isLoading;
});
