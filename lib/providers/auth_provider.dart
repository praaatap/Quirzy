import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:quirzy/utils/appwrite.dart';

class AuthState {
  final String? email;
  final String? password;
  final String? username;
  final bool isLoading;
  final String? error;
  final models.User? user;
  final File? profileImage;
  final bool isUploadingImage;

  AuthState({
    this.email,
    this.password,
    this.username,
    this.isLoading = false,
    this.error,
    this.user,
    this.profileImage,
    this.isUploadingImage = false,
  });

  AuthState copyWith({
    String? email,
    String? password,
    String? username,
    bool? isLoading,
    String? error,
    models.User? user,
    File? profileImage,
    bool? isUploadingImage,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      profileImage: profileImage ?? this.profileImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final Account _account;
  late final Storage _storage;
  final ImagePicker _imagePicker = ImagePicker();

  AuthNotifier(this.ref) : super(AuthState()) {
    final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1') 
      .setProject(APPWRITE_PROJECT_ID); 
    _account = Account(client);
    _storage = Storage(client); 
    _checkAuthStatus();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateUsername(String username) {
    state = state.copyWith(username: username);
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await _account.get();
      state = state.copyWith(user: user);
    } catch (_) {
      state = state.copyWith(user: null);
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      state = state.copyWith(isUploadingImage: true, error: null);
      
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) {
        state = state.copyWith(isUploadingImage: false);
        return;
      }

      // Update state with selected image
      state = state.copyWith(profileImage: File(pickedFile.path));

      // Process and upload
      final String? fileId = await compute(_processAndUploadImage, pickedFile.path);
      
      if (fileId == null) {
        throw Exception('Failed to process image');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isUploadingImage: false);
    }
  }

  Future<String?> _processAndUploadImage(String imagePath) async {
    try {
      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        '${imagePath}_compressed.jpg',
        quality: 85,
        minWidth: 600,
        minHeight: 600,
      );
      
      if (compressedFile == null) return null;

      // Upload to Appwrite
      final file = await _storage.createFile(
        bucketId: '6856a5c600204373c57f',
        fileId: ID.unique(),
        file: InputFile(path: compressedFile.path),
      );
      
      return file.$id;
    } catch (e) {
      debugPrint('Image processing error: $e');
      return null;
    }
  }

  Future<void> signInwithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _account.createOAuth2Session(provider: OAuthProvider.google);
      
      final user = await _account.get();
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signIn() async {
    if (state.email == null || state.password == null) {
      state = state.copyWith(error: 'Email and password are required');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _account.createEmailPasswordSession(
        email: state.email!,
        password: state.password!,
      );
      
      final user = await _account.get();
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signUp() async {
    if (state.email == null || state.password == null || state.username == null) {
      state = state.copyWith(error: 'All fields are required');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _account.create(
        userId: ID.unique(),
        email: state.email!,
        password: state.password!,
        name: state.username!,
      );
      
      await signIn();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _account.deleteSession(sessionId: 'current');
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final file = await _storage.createFile(
        bucketId: '6856a5c600204373c57f', 
        fileId: ID.unique(),
        file: InputFile(path: filePath),
      );
      
      state = state.copyWith(isLoading: false);
      return file.$id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});