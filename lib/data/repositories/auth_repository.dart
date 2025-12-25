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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quirzy/data/datasources/local/auth_local_datasource.dart';
import 'package:quirzy/data/datasources/remote/auth_remote_datasource.dart';
import 'package:quirzy/data/models/user_model.dart';

/// Repository for authentication operations
/// Coordinates between remote API and local storage
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
    GoogleSignIn? googleSignIn,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _localDataSource = localDataSource ?? AuthLocalDataSource(),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  // Web Client ID for Google Sign-In
  static const String _webClientId =
      '960586519952-ea8bh3sj6ki3d5jh38lev36414ibrk73.apps.googleusercontent.com';

  /// Initialize Google Sign-In
  Future<void> initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);
      debugPrint('✅ Google Sign-In initialized');
    } catch (e) {
      debugPrint('⚠️ Google Sign-In initialization error: $e');
    }
  }

  /// Sign up with email, password, and username
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _remoteDataSource.signUp(
        email: email,
        password: password,
        username: username,
      );

      final token = response['token'] as String;

      // Save to local storage
      await _localDataSource.saveUserData(
        token: token,
        email: email,
        username: username,
      );

      return UserModel(email: email, username: username, token: token);
    } catch (e) {
      debugPrint('❌ SignUp repository error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );

      final token = response['token'] as String;
      final username = response['name'] as String? ?? email.split('@')[0];

      // Save to local storage
      await _localDataSource.saveUserData(
        token: token,
        email: email,
        username: username,
      );

      return UserModel(email: email, username: username, token: token);
    } catch (e) {
      debugPrint('❌ SignIn repository error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Initialize first
      await _googleSignIn.initialize(serverClientId: _webClientId);

      debugPrint('🔄 Starting Google Sign-In...');

      final GoogleSignInAccount? user = await _googleSignIn.authenticate();

      if (user == null) {
        throw Exception('Sign in was cancelled');
      }

      final googleAuth = await user.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Failed to get ID token from Google. Please check Firebase configuration.',
        );
      }

      debugPrint('✅ ID Token received');

      // Send to backend
      final response = await _remoteDataSource.googleAuth(
        idToken: googleAuth.idToken!,
      );

      final token = response['token'] as String;
      final username = user.displayName ?? user.email.split('@')[0];

      // Save to local storage
      await _localDataSource.saveUserData(
        token: token,
        email: user.email,
        username: username,
      );

      return UserModel(email: user.email, username: username, token: token);
    } on GoogleSignInException catch (e) {
      debugPrint('❌ Google Sign-In Exception: ${e.code} - ${e.description}');

      String errorMessage = 'Sign in failed';
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          errorMessage = 'Sign in was cancelled';
          break;
        case GoogleSignInExceptionCode.clientConfigurationError:
          errorMessage =
              'Configuration error. Please check SHA-1 fingerprints in Firebase Console';
          break;
        default:
          errorMessage = e.description ?? 'Sign in failed. Please try again';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Check if user is logged in and verify token
  Future<UserModel?> checkAuthStatus() async {
    try {
      debugPrint('🔍 Checking auth status...');

      final userData = await _localDataSource.getUserData();
      final token = userData['token'];

      if (token == null || token.isEmpty) {
        debugPrint('ℹ️ No token found');
        return null;
      }

      // Verify with backend
      final isValid = await _remoteDataSource.verifyToken(token: token);

      if (isValid) {
        debugPrint('✅ User authenticated');
        return UserModel(
          email: userData['email'],
          username: userData['username'],
          token: token,
        );
      } else {
        debugPrint('❌ Token invalid, clearing data');
        await _localDataSource.clearUserData();
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Error checking auth status: $e');
      return null;
    }
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🔄 Signing out...');

      // Sign out from Google if needed
      try {
        await _googleSignIn.signOut();
        debugPrint('✅ Google sign out successful');
      } catch (e) {
        debugPrint('⚠️ Google sign out warning: $e');
      }

      // Clear local data
      await _localDataSource.clearUserData();

      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('⚠️ Sign out error: $e');
      // Still clear local data
      await _localDataSource.clearUserData();
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }

  /// Save FCM token
  Future<void> saveFcmToken(String fcmToken) async {
    final token = await _localDataSource.getToken();
    if (token != null) {
      await _remoteDataSource.saveFcmToken(
        fcmToken: fcmToken,
        authToken: token,
      );
      await _localDataSource.saveFcmToken(fcmToken);
    }
  }

  /// Get all users (admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await _localDataSource.getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }
    return await _remoteDataSource.getAllUsers(token: token);
  }
}
