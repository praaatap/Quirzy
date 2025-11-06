// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final fcmServiceProvider = Provider<FCMService>((ref) => FCMService(ref));

// class FCMService {
//   final Ref _ref;
//   FCMService(this._ref);

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initialize() async {
//     try {
//       // Request notification permissions
//       final settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         // Get the FCM token
//         await _getAndSendToken();

//         // Listen for token refreshes
//         _firebaseMessaging.onTokenRefresh.listen((newToken) {
//           _sendTokenToBackend(newToken);
//         });
//       }
//     } catch (e) {
//       print("FCM initialization error: $e");
//     }
//   }

//   Future<void> _getAndSendToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         await _sendTokenToBackend(token);
//       }
//     } catch (e) {
//       print("Error getting/sending FCM token: $e");
//     }
//   }

//   Future<void> _sendTokenToBackend(String token) async {
//     try {
//       final apiService = _ref.read(apiServiceProvider);
//       await apiService.saveFcmToken(token);
//       print("FCM token successfully sent to backend: $token");
//     } catch (e) {
//       print("Error sending FCM token to backend: $e");
//     }
//   }
// }