import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectionProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult != ConnectivityResult.none;
  
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
});