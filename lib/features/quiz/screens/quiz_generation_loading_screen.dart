import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizGenerationLoadingScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const QuizGenerationLoadingScreen({
    super.key,
    this.title = 'Designing your Quiz...',
    this.subtitle =
        'AI is analyzing the topic and\ncurating the perfect questions.',
  });

  @override
  State<QuizGenerationLoadingScreen> createState() =>
      _QuizGenerationLoadingScreenState();
}

class _QuizGenerationLoadingScreenState
    extends State<QuizGenerationLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _colors = [
    const Color(0xFF4285F4), // Blue
    const Color(0xFF64B5F6), // Light Blue
    const Color(0xFF1E88E5), // Dark Blue
    const Color(0xFF0D47A1), // Deep Blue
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFFFFFF);
    final textColor = isDark ? Colors.white : const Color(0xFF120D1B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Blue Wave Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _GeminiWavePainter(
                  animationValue: _controller.value,
                  colors: _colors,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 2. Central Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Static Icon with Spinning Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning Outer Ring
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF4285F4),
                      ),
                    ),
                  ),
                  // Static Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Text Content
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Bottom Close Button (Emergency Exit)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white30 : Colors.black26,
                ),
                child: Text(
                  'Cancel Generation',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeminiWavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final bool isDark;

  _GeminiWavePainter({
    required this.animationValue,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // maxRadius removed as it was unused

    // We will draw multiple "blobs" moving in Lissajous-like paths
    for (int i = 0; i < 4; i++) {
      final color = colors[i % colors.length];

      // Calculate individual movement for each blob based on animationValue
      // Offset phase for each blob
      final phase = i * (math.pi / 2);
      // Movement radius factor
      final moveRadius = 60.0 + (i * 20.0);

      final dx = math.sin((animationValue * 2 * math.pi) + phase) * moveRadius;
      final dy =
          math.cos((animationValue * 2 * math.pi * 0.7) + phase) *
          moveRadius; // different frequency

      final blobCenter = center + Offset(dx, dy);

      // Base radius of the blob
      // Pulse size
      final sizePulse =
          math.sin((animationValue * 2 * math.pi * 1.5) + phase) * 20.0;
      final radius = 100.0 + (i * 30.0) + sizePulse;

      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                color.withOpacity(isDark ? 0.35 : 0.4),
                color.withOpacity(0.0),
              ],
              stops: const [0.0, 1.0],
            ).createShader(
              Rect.fromCircle(center: blobCenter, radius: radius * 2),
            ) // Larger gradient area
        ..blendMode = isDark
            ? BlendMode.screen
            : BlendMode.multiply; // Blending for glow effect

      canvas.drawCircle(blobCenter, radius * 1.5, paint);
    }

    // Add a global "Wave" coming from corners
    // We simulate this by drawing large circles from corners with very subtle opacity
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    for (int i = 0; i < corners.length; i++) {
      final phase = i * (math.pi / 2);
      final pulse = math.sin((animationValue * 2 * math.pi) + phase);
      final radius = (size.width * 0.4) + (pulse * 30.0);

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(0.05)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(corners[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeminiWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
