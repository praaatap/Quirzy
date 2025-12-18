import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/providers/auth_provider.dart';
import 'package:quirzy/providers/connection_provider.dart';
import 'package:quirzy/screen/NoInternetScreen.dart';
import 'package:quirzy/screen/introduction/welcome.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:quirzy/service/ad_service.dart';
import 'package:quirzy/theme/theme.dart';
import 'package:quirzy/widgets/loadingScreen.dart';
import 'package:showcaseview/showcaseview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp();

  // Use one ProviderContainer to initialize stuff BEFORE first frame
  final container = ProviderContainer();

  final startTime = DateTime.now();

  try {
    await Future.wait([
      container.read(authProvider.notifier).initializeAuth(),
      AdService().initialize(),
    ]);

    // Notification init can be after those two
    container.read(notificationProvider.notifier).initialize();
  } catch (e) {
    debugPrint('⚠️ Initialization error: $e');
  } finally {
    // Keep your minimum splash duration logic if you want
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 500) {
      await Future.delayed(
        Duration(milliseconds: 500 - elapsed.inMilliseconds),
      );
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

// ---------------------- MY APP ---------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quirzy',
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,

      // Wrap navigator output once, doesn’t rebuild when providers change
      builder: (context, child) {
        return Stack(
          children: [
            ShowCaseWidget(
              builder: (context) => child!,
            ),
            const GlobalInternetOverlay(),
          ],
        );
      },

      home: const AuthWrapperOrSplash(),
    );
  }
}

// ---------------------- SPLASH + AUTH WRAPPER ------------------------
// This widget decides whether to show Splash or Auth result.
// It listens to authProvider only here (small rebuild area).
class AuthWrapperOrSplash extends ConsumerWidget {
  const AuthWrapperOrSplash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isInitialized) {
      return const SplashScreen();
    }

    if (authState.isLoggedIn) {
      return const MainScreen();
    }
    return const QuiryHome();
  }
}

// ---------------------- GLOBAL OVERLAY WIDGET -----------------------
class GlobalInternetOverlay extends ConsumerWidget {
  const GlobalInternetOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);

    return connectionState.when(
      data: (hasConnection) {
        if (!hasConnection) {
          return Positioned.fill(
            child: NoInternetScreen(
              onRetry: () {
                ref.invalidate(connectionProvider);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
