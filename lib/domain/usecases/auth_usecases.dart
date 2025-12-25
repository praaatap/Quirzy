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

import 'package:quirzy/data/models/user_model.dart';
import 'package:quirzy/data/repositories/auth_repository.dart';

/// Use cases for authentication operations
/// Contains the business logic for auth-related actions
class AuthUseCases {
  final AuthRepository _repository;

  AuthUseCases({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  /// Initialize Google Sign-In
  Future<void> initializeGoogleSignIn() async {
    await _repository.initializeGoogleSignIn();
  }

  /// Check authentication status
  /// Returns user if authenticated, null otherwise
  Future<UserModel?> checkAuthStatus() async {
    return await _repository.checkAuthStatus();
  }

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      throw Exception('All fields are required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (username.length < 2) {
      throw Exception('Username must be at least 2 characters');
    }

    return await _repository.signUp(
      email: email.trim(),
      password: password.trim(),
      username: username.trim(),
    );
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    return await _repository.signIn(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    return await _repository.signInWithGoogle();
  }

  /// Sign out
  Future<void> signOut() async {
    await _repository.signOut();
  }

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    await _repository.resetPassword(
      email: email.trim(),
      newPassword: newPassword.trim(),
    );
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    return await _repository.getToken();
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken(String fcmToken) async {
    await _repository.saveFcmToken(fcmToken);
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _repository.getAllUsers();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
