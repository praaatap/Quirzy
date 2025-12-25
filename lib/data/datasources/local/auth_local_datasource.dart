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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local data source for authentication data
/// Handles secure storage of tokens and user data
class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'token';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'user_name';
  static const String _fcmTokenKey = 'fcmToken';

  /// Save authentication token
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('✅ Token saved');
    } catch (e) {
      debugPrint('❌ Save token error: $e');
      rethrow;
    }
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('❌ Get token error: $e');
      return null;
    }
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      debugPrint('✅ Token deleted');
    } catch (e) {
      debugPrint('❌ Delete token error: $e');
    }
  }

  /// Save user email
  Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: _emailKey, value: email);
    } catch (e) {
      debugPrint('❌ Save email error: $e');
      rethrow;
    }
  }

  /// Get stored email
  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (e) {
      debugPrint('❌ Get email error: $e');
      return null;
    }
  }

  /// Delete email
  Future<void> deleteEmail() async {
    try {
      await _storage.delete(key: _emailKey);
    } catch (e) {
      debugPrint('❌ Delete email error: $e');
    }
  }

  /// Save username
  Future<void> saveUsername(String username) async {
    try {
      await _storage.write(key: _usernameKey, value: username);
    } catch (e) {
      debugPrint('❌ Save username error: $e');
      rethrow;
    }
  }

  /// Get stored username
  Future<String?> getUsername() async {
    try {
      return await _storage.read(key: _usernameKey);
    } catch (e) {
      debugPrint('❌ Get username error: $e');
      return null;
    }
  }

  /// Delete username
  Future<void> deleteUsername() async {
    try {
      await _storage.delete(key: _usernameKey);
    } catch (e) {
      debugPrint('❌ Delete username error: $e');
    }
  }

  /// Save FCM token
  Future<void> saveFcmToken(String fcmToken) async {
    try {
      await _storage.write(key: _fcmTokenKey, value: fcmToken);
    } catch (e) {
      debugPrint('❌ Save FCM token error: $e');
      rethrow;
    }
  }

  /// Get stored FCM token
  Future<String?> getFcmToken() async {
    try {
      return await _storage.read(key: _fcmTokenKey);
    } catch (e) {
      debugPrint('❌ Get FCM token error: $e');
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteFcmToken() async {
    try {
      await _storage.delete(key: _fcmTokenKey);
    } catch (e) {
      debugPrint('❌ Delete FCM token error: $e');
    }
  }

  /// Save all user data at once
  Future<void> saveUserData({
    required String token,
    required String email,
    required String username,
  }) async {
    await Future.wait([
      saveToken(token),
      saveEmail(email),
      saveUsername(username),
    ]);
    debugPrint('✅ All user data saved');
  }

  /// Get all user data
  Future<Map<String, String?>> getUserData() async {
    final results = await Future.wait([getToken(), getEmail(), getUsername()]);
    return {'token': results[0], 'email': results[1], 'username': results[2]};
  }

  /// Clear all stored auth data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All auth data cleared');
    } catch (e) {
      debugPrint('❌ Clear all error: $e');
    }
  }

  /// Clear user-specific data (on logout)
  Future<void> clearUserData() async {
    await Future.wait([
      deleteToken(),
      deleteEmail(),
      deleteUsername(),
      deleteFcmToken(),
    ]);
    debugPrint('✅ User data cleared');
  }

  /// Check if authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
