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
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _gradientController;
  late Animation<double> _pulseAnimation;

  // Multi-color palette - vibrant and modern
  final List<Color> _colors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF14B8A6), // Teal
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF59E0B), // Amber
  ];

  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    'Analyzing topic...',
    'Generating questions...',
    'Crafting answers...',
    'Adding difficulty levels...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Cycle through loading messages
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _startMessageCycle();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Animated Multi-Color Wave Background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: _MultiColorWavePainter(
                  animationValue: _waveController.value,
                  colors: _colors,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 2. Central Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated AI Icon with Multi-Color Ring
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Gradient Ring
                      AnimatedBuilder(
                        animation: _gradientController,
                        builder: (context, child) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                startAngle:
                                    _gradientController.value * 2 * math.pi,
                                colors: [
                                  _colors[0],
                                  _colors[1],
                                  _colors[2],
                                  _colors[3],
                                  _colors[4],
                                  _colors[0],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner Dark Circle
                      Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                        ),
                      ),
                      // Spinning Progress Indicator
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                      ),
                      // Center Icon with Gradient
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_colors[0], _colors[1], _colors[2]],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Title with Gradient Text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [_colors[0], _colors[1], _colors[2]],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Animated Loading Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey(_currentMessageIndex),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _colors[_currentMessageIndex % _colors.length],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _loadingMessages[_currentMessageIndex],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Progress Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isActive = index <= _currentMessageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? _colors[index % _colors.length]
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 3. Bottom Cancel Button
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                label: Text(
                  'Cancel',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white30 : Colors.black26,
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

class _MultiColorWavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final bool isDark;

  _MultiColorWavePainter({
    required this.animationValue,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw flowing multi-color blobs
    for (int i = 0; i < 6; i++) {
      final color = colors[i % colors.length];
      final phase = i * (math.pi / 3);

      // Calculate flowing movement
      final moveRadius = 80.0 + (i * 25.0);
      final speedMultiplier = 1.0 + (i * 0.15);

      final dx =
          math.sin((animationValue * speedMultiplier * 2 * math.pi) + phase) *
          moveRadius;
      final dy =
          math.cos(
            (animationValue * speedMultiplier * 2 * math.pi * 0.6) + phase,
          ) *
          moveRadius;

      final blobCenter = center + Offset(dx, dy - 50); // Shift up slightly

      // Pulsing size
      final sizePulse =
          math.sin((animationValue * 2 * math.pi * 1.2) + phase) * 25.0;
      final radius = 80.0 + (i * 20.0) + sizePulse;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(isDark ? 0.25 : 0.20),
            color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: blobCenter, radius: radius * 2))
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(blobCenter, radius * 1.8, paint);
    }

    // Add subtle corner accents
    final cornerPositions = [
      Offset(-size.width * 0.1, -size.height * 0.1),
      Offset(size.width * 1.1, size.height * 0.2),
      Offset(-size.width * 0.1, size.height * 1.1),
      Offset(size.width * 1.1, size.height * 0.8),
    ];

    for (int i = 0; i < cornerPositions.length; i++) {
      final phase = i * (math.pi / 2);
      final pulse = math.sin((animationValue * 2 * math.pi * 0.5) + phase);
      final radius = (size.width * 0.35) + (pulse * 20.0);

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(isDark ? 0.08 : 0.05)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.drawCircle(cornerPositions[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiColorWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
