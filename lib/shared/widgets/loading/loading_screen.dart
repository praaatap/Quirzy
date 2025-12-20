import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // read these once to avoid repeated work
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate a proper cache size for the displayed image (120 logical px)
    final cacheSize = (120 * devicePixelRatio).round();

    return RepaintBoundary( // avoids unnecessary repaints of parent widgets
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Keep asset small and decoded at required size
              Image.asset(
                'assets/splash/splash.png',
                width: 120,
                height: 120,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                filterQuality: FilterQuality.low, // faster decode
                // key: const ValueKey('splash-image'), // optional stable key
              ),

              const SizedBox(height: 20),

              // CupertinoActivityIndicator is already lightweight and GPU accelerated
              CircularProgressIndicator(
                strokeWidth: 2.0,
                color: isDark ? Colors.white : Colors.black,
              ),

              const SizedBox(height: 30),

              const Text(
                'Loading — please wait...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
