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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/utils/constant.dart';

/// Remote data source for authentication-related API calls
/// Handles all HTTP communication with the auth endpoints
class AuthRemoteDataSource {
  final http.Client _client;

  AuthRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  /// Sign up with email, password and username
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      debugPrint('📤 Sending signup request...');

      final uri = Uri.parse('$kBackendApiUrl/signup');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': username,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Signup successful');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📤 Sending signin request...');

      final response = await _client.post(
        Uri.parse('$kBackendApiUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Signin successful');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('❌ Signin error: $e');
      rethrow;
    }
  }

  /// Authenticate with Google ID token
  Future<Map<String, dynamic>> googleAuth({required String idToken}) async {
    try {
      debugPrint('📤 Sending Google auth request...');

      final response = await _client.post(
        Uri.parse('$kBackendApiUrl/auth/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Google auth successful');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to authenticate with Google');
      }
    } catch (e) {
      debugPrint('❌ Google auth error: $e');
      rethrow;
    }
  }

  /// Verify authentication token
  Future<bool> verifyToken({required String token}) async {
    try {
      debugPrint('🔐 Verifying token...');

      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/auth/verify'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint('✅ Token verified');
        return true;
      } else {
        debugPrint('❌ Token verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Token verification error: $e');
      // Return true on network error to allow offline access
      return true;
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔑 Resetting password...');

      final response = await _client
          .post(
            Uri.parse('$kBackendApiUrl/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Password reset successful');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken({
    required String fcmToken,
    required String authToken,
  }) async {
    try {
      debugPrint('💾 Saving FCM token...');

      final response = await _client
          .post(
            Uri.parse('$kBackendApiUrl/auth/save-token'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token saved');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save FCM token');
      }
    } catch (e) {
      debugPrint('❌ Save FCM token error: $e');
      rethrow;
    }
  }

  /// Get all users (admin)
  Future<List<Map<String, dynamic>>> getAllUsers({
    required String token,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$kBackendApiUrl/users'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to get users');
      }
    } catch (e) {
      debugPrint('❌ Get all users error: $e');
      rethrow;
    }
  }
}
