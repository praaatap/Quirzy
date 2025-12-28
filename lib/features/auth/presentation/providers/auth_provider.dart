import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/models/user_model.dart';
import 'package:quirzy/di/injection_container.dart';

/// Auth Provider (Manual Riverpod Implementation)
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    // Initial check for login status
    return await ref.read(authRepositoryProvider).checkLoginStatus();
  }

  // --- Actions ---

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
    });
  }

  Future<void> signUp(String email, String password, String username) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, username: username);
    });
  }

  Future<void> googleSignIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryProvider).googleSignIn();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
    });
    // Set state to null (logged out)
    state = const AsyncValue.data(null);
  }

  Future<void> saveFcmToken() async {
    final user = state.value;
    if (user != null) {
      try {
        await ref
            .read(authRepositoryProvider)
            .saveFcmToken(user.username ?? 'unknown');
      } catch (e) {
        debugPrint('Failed to save FCM token: $e');
      }
    }
  }
}
