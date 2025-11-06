import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/firebase_options.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/screen/introduction/onboarding.dart';
import 'package:quirzy/screen/introduction/welcome.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/theme/theme.dart';
import 'package:quirzy/widgets/internet_connection_wrapper.dart';
import 'package:quirzy/widgets/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Background Handler - ONLY checks if Firebase is initialized
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ✅ Only initialize if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  debugPrint('🔔 Background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

// ✅ Onboarding Provider
final onboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_done') ?? false;
});

// ✅ CORRECTED main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase ONCE at the start
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Register background handler AFTER Firebase initialization
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    await ref.read(notificationProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.isLoggedIn && next.token != null) {
        ref.read(notificationProvider.notifier).sendTokenToBackend(next.token);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quirzy',
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const InternetConnectionWrapper(
        child: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final authState = ref.watch(authProvider);

    return onboarding.when(
      data: (onboardingDone) {
        if (!authState.isInitialized || authState.isLoading) {
          return const SplashScreen();
        }

        if (!onboardingDone) {
          return OnboardingScreen();
        }

        if (authState.isLoggedIn) {
          return const MainScreen();
        }

        return const QuiryHome();
      },

      loading: () => const SplashScreen(),

      error: (err, stack) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Error loading app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(onboardingProvider);
                  ref.read(authProvider.notifier).checkLoginStatus();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
