import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart';
import '../../../core/di/app_providers.dart';
import '../entities/auth_user.dart';

/// Sign In With Google Use Case - handles Google authentication
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(authService: ref.watch(authServiceProvider));
});

class SignInWithGoogleUseCase {
  final dynamic _authService;

  SignInWithGoogleUseCase({required dynamic authService})
      : _authService = authService;

  Future<AuthUser> call() async {
    final User user = await _authService.signInWithGoogle();
    final prefs = user.prefs.data;
    return AuthUser(
      id: user.$id,
      email: user.email,
      name: user.name,
      photoUrl: prefs['photoUrl'] as String?,
    );
  }
}
