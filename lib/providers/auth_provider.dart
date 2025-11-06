import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/utils/constant.dart';

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
  AuthNotifier() : super(AuthState.initial()) {
    // Initialize auth on provider creation
    _initializeAuth();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Private method to handle initialization
  Future<void> _initializeAuth() async {
    await initialize();
    await checkLoginStatus();
  }

  Future<void> initialize() async {
    _googleSignIn.initialize(
      clientId:
          '908203960958-9u6gq8elpinjop2k41m7o8et42e1imje.apps.googleusercontent.com',
      serverClientId:
          '908203960958-24a3a2odtq07jaea5h9nb7f4hfjoi9c3.apps.googleusercontent.com',
    );
  }

  Future<void> initializeAndAuthenticateGoogle() async {
    try {
      state = state.copyWith(isGoogleSigningIn: true, error: null);

      // CRITICAL: Initialize must be called first with serverClientId
      await _googleSignIn.initialize(
        clientId:
            '908203960958-9u6gq8elpinjop2k41m7o8et42e1imje.apps.googleusercontent.com',
        serverClientId:
            '908203960958-24a3a2odtq07jaea5h9nb7f4hfjoi9c3.apps.googleusercontent.com',
      );

      // Use authenticate() - this is CORRECT for v7.x
      final GoogleSignInAccount user = await _googleSignIn.authenticate();

      // Get authentication tokens
      final googleAuth = await user.authentication;

      debugPrint('ID Token: ${googleAuth.idToken}');

      // Send to backend
      final response = await http.post(
        Uri.parse('${kBackendApiUrl}/auth/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        state = state.copyWith(
          isLoggedIn: true,
          token: data['token'],
          email: user.email,
          username: user.displayName ?? user.email.split('@')[0],
          isGoogleSigningIn: false,
          error: null,
        );
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to authenticate with Google');
      }
    } on GoogleSignInException catch (e) {
      debugPrint('Google Sign-In Error: ${e.code} - ${e.description}');
      state = state.copyWith(
          error: e.description ?? 'Sign in failed', isGoogleSigningIn: false);
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      state = state.copyWith(error: e.toString(), isGoogleSigningIn: false);
      rethrow;
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
        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          token: data['token'],
          error: null,
        );
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

  Future<void> checkLoginStatus() async {
    try {
      // Set loading state for auth check
      state = state.copyWith(isLoading: true, isInitialized: false);
      
      final token = await _storage.read(key: 'token');
      
      if (token != null && token.isNotEmpty) {
        // Token exists, verify it's still valid (optional but recommended)
        final isValid = await _verifyToken(token);
        
        if (isValid) {
          state = state.copyWith(
            isLoggedIn: true,
            token: token,
            isLoading: false,
            isInitialized: true,
          );
          debugPrint('✅ User is authenticated, auto-switching to main screen');
        } else {
          // Token is invalid, clear it
          await _storage.delete(key: 'token');
          state = state.copyWith(
            isLoggedIn: false,
            token: null,
            isLoading: false,
            isInitialized: true,
          );
          debugPrint('❌ Token invalid, showing welcome screen');
        }
      } else {
        // No token found, user is logged out
        state = state.copyWith(
          isLoggedIn: false,
          token: null,
          isLoading: false,
          isInitialized: true,
        );
        debugPrint('ℹ️ No token found, showing welcome screen');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking login status: $e');
      // Error reading storage, treat as logged out
      await logout();
    } finally {
      // Ensure initialized is always set to true after check
      if (!state.isInitialized) {
        state = state.copyWith(isLoading: false, isInitialized: true);
      }
    }
  }

  // Optional: Verify token with backend
  Future<bool> _verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${kBackendApiUrl}/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ Token verified successfully');
        return true;
      } else {
        debugPrint('❌ Token verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Token verification error: $e');
      // If backend is unreachable, assume token is valid
      // You can change this to return false for stricter security
      return true;
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
        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          token: data['token'],
          error: null,
        );
        debugPrint('✅ Login successful');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      debugPrint('❌ Login Error: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Sign out from Google (if user signed in with Google)
      await _googleSignIn.signOut();

      // Delete stored token
      await _storage.delete(key: 'token');

      // Optionally: Notify backend about logout (if needed)
      // await _notifyBackendLogout();

      // Reset state completely with all fields cleared
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

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('⚠️ Logout Error: $e');

      // Even if Google sign out fails, still clear local data
      await _storage.delete(key: 'token');
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

// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
