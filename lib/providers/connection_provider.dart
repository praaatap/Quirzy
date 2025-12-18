import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectionProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Check initial status
  final initialResult = await connectivity.checkConnectivity();
  
  // Helper function to check if connected (handles both List and single result)
  bool isConnected(dynamic result) {
    if (result is List) {
      return !result.contains(ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }

  yield isConnected(initialResult);
  
  // Listen to stream updates
  await for (final result in connectivity.onConnectivityChanged) {
    yield isConnected(result);
  }
});