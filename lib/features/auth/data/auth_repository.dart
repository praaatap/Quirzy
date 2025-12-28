import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/models/user_model.dart';
import 'package:quirzy/core/constants/constant.dart';
import 'package:quirzy/core/services/storage/token_storage.dart';

class AuthRepository {
  final _googleSignIn = GoogleSignIn.instance;

  static const _clientId =
      '960586519952-ea8bh3sj6ki3d5jh38lev36414ibrk73.apps.googleusercontent.com';

  Future<void> initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _clientId);
      debugPrint('✅ Google Sign-In initialized');
    } catch (e) {
      debugPrint('⚠️ Google Sign-In initialization error: $e');
    }
  }

  Future<UserModel?> checkLoginStatus() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return null;

      final isValid = await _verifyToken(token);
      if (isValid) {
        final email = await TokenStorage.getEmail() ?? '';
        final username = await TokenStorage.getName() ?? '';
        return UserModel(email: email, username: username, token: token);
      } else {
        await logout();
        return null;
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return null;
    }
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$kBackendApiUrl/auth/verify'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token verification error: $e');
      return true; // Assuming valid if network error, dangerous but consistent with original
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBackendApiUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final username = data['name'] ?? email.split('@')[0];

        await TokenStorage.saveToken(token);
        await TokenStorage.saveEmail(email);
        await TokenStorage.saveName(username);

        return UserModel(email: email, username: username, token: token);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBackendApiUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': username,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        await TokenStorage.saveToken(token);
        await TokenStorage.saveEmail(email);
        await TokenStorage.saveName(username);

        return UserModel(email: email, username: username, token: token);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> googleSignIn() async {
    try {
      await initializeGoogleSignIn();
      final GoogleSignInAccount? user = await _googleSignIn.authenticate();

      if (user == null) {
        throw Exception('Sign in was cancelled');
      }

      final googleAuth = user.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google.');
      }

      final response = await http.post(
        Uri.parse('$kBackendApiUrl/auth/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final username = user.displayName ?? user.email.split('@')[0];

        await TokenStorage.saveToken(token);
        await TokenStorage.saveEmail(user.email);
        await TokenStorage.saveName(username);

        return UserModel(email: user.email, username: username, token: token);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Google authenticate failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await TokenStorage.clearAll();
  }

  Future<void> saveFcmToken(String userId) async {
    try {
      final fcm = FirebaseMessaging.instance;
      final settings = await fcm.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await fcm.getToken();
        if (token != null) {
          await http.post(
            Uri.parse('$kBackendApiUrl/auth/save-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId, 'fcmToken': token}),
          );
        }
      }
    } catch (e) {
      debugPrint("FCM Error: $e");
    }
  }
}
