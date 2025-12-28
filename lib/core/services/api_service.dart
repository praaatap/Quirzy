import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/core/constants/constant.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // ==================== AUTHENTICATION ====================

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      debugPrint('❌ Get token error: $e');
      return null;
    }
  }

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'token', value: token);
      debugPrint('✅ Token saved successfully');
    } catch (e) {
      debugPrint('❌ Save token error: $e');
      rethrow;
    }
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'token');
      debugPrint('✅ Token deleted successfully');
    } catch (e) {
      debugPrint('❌ Delete token error: $e');
    }
  }


  /// Get all users (for testing/admin)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('$kBackendApiUrl/users');

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to get users');
      }
    } catch (e) {
      debugPrint('❌ Get all users error: $e');
      rethrow;
    }
  }


  /// Save FCM token for push notifications
  static Future<void> saveFCMToken(String fcmToken) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('💾 Saving FCM token');

      final uri = Uri.parse('$kBackendApiUrl/auth/save-token');

      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Save FCM Token Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token saved successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save FCM token');
      }
    } catch (e) {
      debugPrint('❌ Save FCM token error: $e');
      rethrow;
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Reset password
  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔑 Resetting password for: $email');

      final uri = Uri.parse('$kBackendApiUrl/reset-password');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Reset Password Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Password reset successfully');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Clear data error: $e');
    }
  }

  static Future<void> saveFcmToken(String fcmToken, String authToken) async {
    try {
      debugPrint('💾 Saving FCM token to backend');

      final uri = Uri.parse('$kBackendApiUrl/auth/save-token');

      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Save FCM Token Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token saved successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save FCM token');
      }
    } catch (e) {
      debugPrint('❌ Save FCM token error: $e');
      rethrow;
    }
  }
}
