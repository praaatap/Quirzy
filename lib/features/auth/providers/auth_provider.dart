import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/utils/constant.dart';
import 'package:flutter_riverpod/legacy.dart';

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
}

final _storage = const FlutterSecureStorage();

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ✅ Public method to initialize auth - called from main app
  Future<void> initializeAuth() async {
    await initialize();
    await checkLoginStatus();
  }

  // ✅ FIXED: Initialize with your Web Client ID
  Future<void> initialize() async {
    try {
      // ✅ CORRECT: This is your Web Client ID (from google-services.json client_type: 3)
      await _googleSignIn.initialize(
        serverClientId:
            '960586519952-ea8bh3sj6ki3d5jh38lev36414ibrk73.apps.googleusercontent.com',
      );

      debugPrint('✅ Google Sign-In initialized');
    } catch (e) {
      debugPrint('⚠️ Google Sign-In initialization error: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      debugPrint('🔍 Checking login status...');

      state = state.copyWith(isInitialized: false, isLoading: true);

      final token = await _storage.read(key: 'token');

      debugPrint(
        '📝 Token from storage: ${token != null ? "Found" : "Not found"}',
      );

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Token exists, verifying...');

        final isValid = await _verifyToken(token);

        if (isValid) {
          final email = await _storage.read(key: 'user_email');
          final username = await _storage.read(key: 'user_name');

          state = state.copyWith(
            isLoggedIn: true,
            token: token,
            email: email,
            username: username,
            isLoading: false,
            isInitialized: true,
          );
          debugPrint('✅ User authenticated, redirecting to main screen');
        } else {
          debugPrint('❌ Token invalid, clearing data');
          await _storage.delete(key: 'token');
          await _storage.delete(key: 'user_email');
          await _storage.delete(key: 'user_name');

          state = state.copyWith(
            isLoggedIn: false,
            token: null,
            email: null,
            username: null,
            isLoading: false,
            isInitialized: true,
          );
        }
      } else {
        debugPrint('ℹ️ No token found, showing welcome screen');
        state = state.copyWith(
          isLoggedIn: false,
          token: null,
          isLoading: false,
          isInitialized: true,
        );
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

  Future<bool> _verifyToken(String token) async {
    try {
      debugPrint('🔐 Verifying token with backend...');

      final response = await http
          .get(
            Uri.parse('${kBackendApiUrl}/auth/verify'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint('✅ Token verified successfully');
        return true;
      } else {
        debugPrint('❌ Token verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Token verification error: $e');
      return true;
    }
  }

  void updateEmail(String value) => state = state.copyWith(email: value.trim());
  void updatePassword(String value) =>
      state = state.copyWith(password: value.trim());
  void updateUsername(String value) =>
      state = state.copyWith(username: value.trim());
  void setIsUploadingImage(bool value) =>
      state = state.copyWith(isUploadingImage: value);
  void updateProfileImage(XFile? image) =>
      state = state.copyWith(profileImage: image);

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
      state = state.copyWith(error: "All fields are required");
      throw Exception("All fields are required");
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final uri = Uri.parse('${kBackendApiUrl}/signup');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': username,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_name', value: username);

        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          token: data['token'],
          email: email,
          username: username,
          error: null,
          isInitialized: true,
        );
        debugPrint('✅ Signup successful');
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('SignUp Error: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await http.post(
        Uri.parse('${kBackendApiUrl}/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user_email', value: email);

        final username = data['name'] ?? email.split('@')[0];
        await _storage.write(key: 'user_name', value: username);

        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          token: data['token'],
          email: email,
          username: username,
          error: null,
          isInitialized: true,
        );
        debugPrint('✅ Login successful');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch  (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('❌ Login Error: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  // ✅ COMPLETE FIXED GOOGLE SIGN-IN METHOD
  Future<void> initializeAndAuthenticateGoogle() async {
    try {
      state = state.copyWith(isGoogleSigningIn: true, error: null);

      // ✅ FIXED: Use your correct Web Client ID (NOT Client Secret)
      // ✅ CORRECT: This is your Web Client ID (from google-services.json client_type: 3)
      await _googleSignIn.initialize(
        serverClientId:
            '960586519952-ea8bh3sj6ki3d5jh38lev36414ibrk73.apps.googleusercontent.com',
      );

      debugPrint('🔄 Starting Google Sign-In...');

      // ✅ Use authenticate() method for google_sign_in 7.x
      final GoogleSignInAccount? user = await _googleSignIn.authenticate();

      // ✅ Check if user cancelled sign-in
      if (user == null) {
        debugPrint('⚠️ User cancelled Google Sign-In');
        state = state.copyWith(
          isGoogleSigningIn: false,
          error: 'Sign in was cancelled',
        );
        return;
      }

      final googleAuth = await user.authentication;

      // ✅ Check if idToken exists
      if (googleAuth.idToken == null) {
        debugPrint('❌ ID Token is null');
        throw Exception(
          'Failed to get ID token from Google. Please check Firebase configuration and SHA-1 fingerprints.',
        );
      }

      debugPrint(
        '✅ ID Token received: ${googleAuth.idToken!.substring(0, 20)}...',
      );

      // Send token to your backend
      final response = await http.post(
        Uri.parse('${kBackendApiUrl}/auth/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user_email', value: user.email);
        await _storage.write(
          key: 'user_name',
          value: user.displayName ?? user.email.split('@')[0],
        );

        state = state.copyWith(
          isLoggedIn: true,
          token: data['token'],
          email: user.email,
          username: user.displayName ?? user.email.split('@')[0],
          isGoogleSigningIn: false,
          error: null,
          isInitialized: true,
        );
        debugPrint('✅ Google sign-in successful');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to authenticate with Google');
      }
    } on GoogleSignInException catch (e) {
      debugPrint('❌ Google Sign-In Exception: ${e.code} - ${e.description}');

      // ✅ Better error messages based on error code
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

      state = state.copyWith(error: errorMessage, isGoogleSigningIn: false);
      rethrow;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      state = state.copyWith(error: e.toString(), isGoogleSigningIn: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      try {
        await _googleSignIn.signOut();
        debugPrint('✅ Google sign out successful');
      } catch (e) {
        debugPrint('⚠️ Google sign out warning: $e');
      }

      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_name');
      await _storage.delete(key: 'fcmToken');

      state = const AuthState(
        isLoggedIn: false,
        isInitialized: true,
        isLoading: false,
        error: null,
        token: null,
        email: null,
        password: null,
        username: null,
        profileImage: null,
        isUploadingImage: false,
        isGoogleSigningIn: false,
      );

      debugPrint('✅ Logout successful - all data cleared');
    } catch (e) {
      debugPrint('⚠️ Logout Error: $e');

      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_name');

      state = const AuthState(
        isLoggedIn: false,
        isInitialized: true,
        error: null,
      );
    }
  }

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
          await sendTokenToBackend(token);
        }
      } else {
        throw Exception("Notification permission denied");
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    final response = await http.post(
      Uri.parse('${kBackendApiUrl}/auth/save-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': state.username, 'fcmToken': token}),
    );

    if (response.statusCode != 200) {
      debugPrint("Failed to save FCM token: ${response.body}");
    } else {
      debugPrint("FCM token saved successfully.");
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
