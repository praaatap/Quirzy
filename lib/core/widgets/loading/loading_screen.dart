import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    const primaryColor = Color(0xFF5B13EC);

    // Light Theme Gradient
    const lightBgTop = Color(0xFFF3E8FF);
    const lightBgBottom = Color(0xFFE0C8FF);

    // Dark Theme Gradient
    const darkBgTop = Color(0xFF161022);
    const darkBgBottom = Color(0xFF2D1C4E);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [darkBgTop, darkBgBottom]
                : [lightBgTop, lightBgBottom],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Logo Composition
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Main Logo Box
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),

                  // Floating Badge 1 (Lightning)
                  Positioned(
                    top: -10,
                    right: 10,
                    child: _FloatingBadge(
                      delay: 0,
                      controller: _controller,
                      icon: Icons.bolt_rounded,
                      isDark: isDark,
                    ),
                  ),

                  // Floating Badge 2 (Note)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _FloatingBadge(
                      delay: 0.5,
                      controller: _controller,
                      icon: Icons.edit_note_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            Text(
              'Quirzy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Generate Quizzes in Seconds',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF6B46C1),
              ),
            ),

            const SizedBox(height: 48),

            // 3-Dot Loader
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return _PulsingDot(
                  index: index,
                  controller: _controller,
                  color: primaryColor,
                );
              }),
            ),

            const Spacer(),

            // Version
            Text(
              'Version 1.0',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final double delay;
  final AnimationController controller;
  final IconData icon;
  final bool isDark;

  const _FloatingBadge({
    required this.delay,
    required this.controller,
    required this.icon,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = (controller.value + delay) % 1.0;
        final offset = -5.0 * (0.5 - (0.5 - val).abs()) * 2; // Ping-pong effect

        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : const Color(0xFF5B13EC),
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Color color;

  const _PulsingDot({
    required this.index,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Staggered opacity
        final val = (controller.value - (index * 0.2)) % 1.0;
        final opacity = (val < 0.5) ? 1.0 : 0.3; // Simple blink
        // Or smooth pulse
        // scale removed

        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity((opacity).clamp(0.2, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
