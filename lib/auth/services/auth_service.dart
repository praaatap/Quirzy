import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import '../../quiz/services/quiz_service.dart'; // Reuse AppwriteClient and Config

/// Auth Service using Appwrite
class AuthService {
  final Account _account = AppwriteClient.instance.account;
  final Databases _db = AppwriteClient.instance.databases;

  static const String usersCollection = 'users';

  // Sign Up
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: usersCollection,
        documentId: user.$id,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'quizCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return user;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Signup failed');
    }
  }

  // Sign In
  Future<User> signIn({required String email, required String password}) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return await _account.get();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Invalid email or password');
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      // This will open a browser - it won't wait for user to complete auth
      // The actual session will be created when user completes OAuth in browser
      // and the deep link redirects back to the app
      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
        success: 'appwrite-callback-695be801003d58b523fc://auth',
        failure: 'appwrite-callback-695be801003d58b523fc://auth',
      );
      // Note: This method returns immediately after launching browser
      // The actual auth completion is handled by DeepLinkService
    } on AppwriteException catch (e) {
      // Handle specific OAuth errors
      if (e.code == 401) {
        throw Exception('OAuth session failed. Please try again.');
      }
      throw Exception(e.message ?? 'Google sign in failed');
    } catch (e) {
      // Catch any other errors (like browser not opening)
      throw Exception(
        'Failed to open Google sign-in. Please check your internet connection.',
      );
    }
  }

  // Sync Google User with Database
  Future<User> syncGoogleUser() async {
    try {
      // 1. Get current account
      final user = await _account.get();

      // Extract photoUrl from prefs if available (requires server-side sync or OAuth scope)
      // For now, checks if it's there.
      final String? photoUrl = user.prefs.data['photoUrl'];

      // 2. Check if user document exists
      try {
        await _db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: usersCollection,
          documentId: user.$id,
        );
        // User exists. Optional: Update login time or photo if changed
        return user;
      } on AppwriteException catch (_) {
        // Document not found (or other error), proceed to create
      }

      // 3. Create user document if it doesn't exist
      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: usersCollection,
        documentId: user.$id,
        data: {
          'name': user.name,
          'email': user.email,
          'password': 'google-auth',
          'photoUrl': photoUrl, // Store Google photo if available
          'quizCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return user;
    } catch (e) {
      print('Sync Error: $e');
      throw Exception('Failed to sync user profile');
    }
  }

  // Get Current User (wraps sync for safety)
  Future<User?> getCurrentUser() async {
    try {
      // Verify session exists first
      await _account.get();
      // Then sync/get full user
      return await syncGoogleUser();
    } catch (_) {
      return null;
    }
  }

  // Is Logged In
  Future<bool> isLoggedIn() async {
    try {
      await _account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Log Out
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Ignore logout errors
    }
  }
}
