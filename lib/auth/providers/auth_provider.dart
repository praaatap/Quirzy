import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/domain.dart';

/// Auth state provider using AsyncNotifier for proper state management
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

/// Auth Notifier - handles login, signup, logout with proper state management
class AuthNotifier extends AsyncNotifier<AuthUser?> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<AuthUser?> build() async {
    // Check for existing session on app start
    return ref.read(getCurrentUserUseCaseProvider).call();
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);
      await _saveUserToStorage(user);
      return user;
    });
  }

  /// Sign up with email, password and name
  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(signUpUseCaseProvider).call(
        email: email,
        password: password,
        name: name,
      );
      await _saveUserToStorage(user);
      return user;
    });
  }

  /// Google Sign In (Native flow - no deep links needed)
  Future<void> googleSignIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      debugPrint('AuthProvider: Starting native Google Sign-In...');
      final user = await ref.read(signInWithGoogleUseCaseProvider).call();
      debugPrint('AuthProvider: Google Sign-In successful: ${user.email}');
      await _saveUserToStorage(user);
      return user;
    });
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(logoutUseCaseProvider).call();
      await _clearStorage();
      return null;
    });
  }

  Future<void> refresh() async {
    try {
      debugPrint('AuthProvider: Refreshing auth state...');
      final user = await ref.read(getCurrentUserUseCaseProvider).call();
      debugPrint('AuthProvider: Got user: ${user?.email ?? 'null'}');
      state = AsyncValue.data(user);
    } catch (e, st) {
      debugPrint('AuthProvider: Refresh error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Save user details to secure storage for quick access
  Future<void> _saveUserToStorage(AuthUser user) async {
    await _storage.write(key: 'user_id', value: user.id);
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_email', value: user.email);
    if (user.photoUrl != null) {
      await _storage.write(key: 'user_photo_url', value: user.photoUrl);
    }
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_photo_url');
  }
}

/// Legacy providers for backward compatibility
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  return Stream.fromFuture(useCase.call());
});

final loadingProvider = StateProvider<bool>((ref) => false);
