import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

/// Provider for AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state provider using AsyncNotifier for proper state management
final authProvider = AsyncNotifierProvider<AuthNotifier, models.User?>(
  AuthNotifier.new,
);

/// Auth Notifier - handles login, signup, logout with proper state management
class AuthNotifier extends AsyncNotifier<models.User?> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<models.User?> build() async {
    // Check for existing session on app start
    final authService = ref.read(authServiceProvider);
    return await authService.getCurrentUser();
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(email: email, password: password);
      await _saveUserToStorage(user);
      return user;
    });
  }

  /// Sign up with email, password and name
  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      await _saveUserToStorage(user);
      return user;
    });
  }

  /// Google Sign In
  Future<void> googleSignIn() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      // This launches the OAuth browser and returns immediately
      // Don't try to get user here - wait for deep link callback
      await authService.signInWithGoogle();

      // Keep loading state - the deep link handler will update with user data
      // when OAuth completes and redirects back to the app
      // state remains as AsyncValue.loading() until deep link callback
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      await _clearStorage();
      return null;
    });
  }


  Future<void> refresh() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    state = AsyncValue.data(user);
  }

  /// Save user details to secure storage for quick access
  Future<void> _saveUserToStorage(models.User user) async {
    await _storage.write(key: 'user_id', value: user.$id);
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_email', value: user.email);
    if (user.prefs.data['photoUrl'] != null) {
      await _storage.write(
        key: 'user_photo_url',
        value: user.prefs.data['photoUrl'],
      );
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
final authStateProvider = StreamProvider<models.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return Stream.fromFuture(authService.getCurrentUser());
});

final loadingProvider = StateProvider<bool>((ref) => false);
