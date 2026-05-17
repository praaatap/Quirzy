import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';

/// Auth Service provider - singleton instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
