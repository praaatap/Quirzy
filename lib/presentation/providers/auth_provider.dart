// ============================================================================
// QUIRZY - PROPRIETARY AND CONFIDENTIAL
// ============================================================================
// Copyright (c) 2025 Quirzy. All Rights Reserved.
//
// This source code is licensed under the Quirzy Proprietary License.
// See the LICENSE file in the root directory for full terms.
//
// UNAUTHORIZED COPYING, MODIFICATION, DISTRIBUTION, OR USE IS STRICTLY
// PROHIBITED. This code is provided for VIEWING PURPOSES ONLY.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:quirzy/data/models/user_model.dart';
import 'package:quirzy/domain/usecases/auth_usecases.dart';

/// Auth state for the presentation layer
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final String? token;
  final String? email;
  final String? password;
  final String? username;
  final XFile? profileImage;
  final bool isUploadingImage;
  final bool isGoogleSigningIn;
  final bool isInitialized;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.token,
    this.email,
    this.password,
    this.username,
    this.profileImage,
    this.isUploadingImage = false,
    this.isGoogleSigningIn = false,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    String? token,
    String? email,
    String? password,
    String? username,
    XFile? profileImage,
    bool? isUploadingImage,
    bool? isGoogleSigningIn,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isGoogleSigningIn: isGoogleSigningIn ?? this.isGoogleSigningIn,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  factory AuthState.initial() => const AuthState(isLoggedIn: false);

  /// Create from UserModel
  factory AuthState.fromUser(UserModel user) {
    return AuthState(
      isLoggedIn: true,
      isInitialized: true,
      token: user.token,
      email: user.email,
      username: user.username,
    );
  }
}

/// Auth notifier for state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthUseCases _useCases;

  AuthNotifier({AuthUseCases? useCases})
    : _useCases = useCases ?? AuthUseCases(),
      super(AuthState.initial());

  /// Initialize auth - call from main app
  Future<void> initializeAuth() async {
    await _useCases.initializeGoogleSignIn();
    await checkLoginStatus();
  }

  /// Check if user is logged in
  Future<void> checkLoginStatus() async {
    try {
      debugPrint('🔍 Checking login status...');
      state = state.copyWith(isInitialized: false, isLoading: true);

      final user = await _useCases.checkAuthStatus();

      if (user != null) {
        state = state.copyWith(
          isLoggedIn: true,
          token: user.token,
          email: user.email,
          username: user.username,
          isLoading: false,
          isInitialized: true,
        );
        debugPrint('✅ User authenticated');
      } else {
        state = state.copyWith(
          isLoggedIn: false,
          token: null,
          email: null,
          username: null,
          isLoading: false,
          isInitialized: true,
        );
        debugPrint('ℹ️ No authenticated user');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking login status: $e');
      state = state.copyWith(
        isLoggedIn: false,
        token: null,
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  // Form field updates
  void updateEmail(String value) => state = state.copyWith(email: value.trim());
  void updatePassword(String value) =>
      state = state.copyWith(password: value.trim());
  void updateUsername(String value) =>
      state = state.copyWith(username: value.trim());
  void setIsUploadingImage(bool value) =>
      state = state.copyWith(isUploadingImage: value);
  void updateProfileImage(XFile? image) =>
      state = state.copyWith(profileImage: image);

  /// Pick profile image
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      state = state.copyWith(isUploadingImage: true);
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        state = state.copyWith(profileImage: image);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isUploadingImage: false);
    }
  }

  /// Sign up with email, password, username
  Future<void> signUp() async {
    final email = state.email;
    final password = state.password;
    final username = state.username;

    if (email == null ||
        password == null ||
        username == null ||
        email.isEmpty ||
        password.isEmpty ||
        username.isEmpty) {
      state = state.copyWith(error: 'All fields are required');
      throw Exception('All fields are required');
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _useCases.signUp(
        email: email,
        password: password,
        username: username,
      );

      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        token: user.token,
        email: user.email,
        username: user.username,
        error: null,
        isInitialized: true,
      );

      debugPrint('✅ Signup successful');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('SignUp Error: $e');
      rethrow;
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _useCases.signIn(email: email, password: password);

      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        token: user.token,
        email: user.email,
        username: user.username,
        error: null,
        isInitialized: true,
      );

      debugPrint('✅ Login successful');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('❌ Login Error: $e');
      rethrow;
    }
  }

  /// Google sign-in
  Future<void> initializeAndAuthenticateGoogle() async {
    try {
      state = state.copyWith(isGoogleSigningIn: true, error: null);

      final user = await _useCases.signInWithGoogle();

      state = state.copyWith(
        isLoggedIn: true,
        token: user.token,
        email: user.email,
        username: user.username,
        isGoogleSigningIn: false,
        error: null,
        isInitialized: true,
      );

      debugPrint('✅ Google sign-in successful');
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      state = state.copyWith(error: e.toString(), isGoogleSigningIn: false);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _useCases.signOut();

      state = const AuthState(
        isLoggedIn: false,
        isInitialized: true,
        isLoading: false,
      );

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('⚠️ Logout Error: $e');
      state = const AuthState(isLoggedIn: false, isInitialized: true);
    }
  }

  /// Register for push notifications
  Future<void> registerForNotifications() async {
    try {
      final fcm = FirebaseMessaging.instance;
      final settings = await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await fcm.getToken();
        if (token != null) {
          await _useCases.saveFcmToken(token);
        }
      } else {
        throw Exception('Notification permission denied');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send token to backend (legacy support)
  Future<void> sendTokenToBackend(String token) async {
    try {
      await _useCases.saveFcmToken(token);
      debugPrint('FCM token saved successfully');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
