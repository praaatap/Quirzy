import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/features/auth/presentation/providers/auth_provider.dart';

class AuthListenator extends ChangeNotifier {
  AuthListenator(Ref ref) {
    ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
  }
}
