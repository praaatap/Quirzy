import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // read these once to avoid repeated work
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return RepaintBoundary(
      // avoids unnecessary repaints of parent widgets
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Native-like simple loading
              CircularProgressIndicator(
                strokeWidth: 3.0,
                color: isDark ? Colors.white : Colors.black,
              ),

              const SizedBox(height: 24),

              Text(
                'Quirzy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
