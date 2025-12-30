import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Loading dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Start logo animation
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // Animated background blobs
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100 * _pulseAnimation.value,
                      right: -80,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primaryColor.withOpacity(isDark ? 0.2 : 0.15),
                              primaryColor.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80 * _pulseAnimation.value,
                      left: -100,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.colorScheme.secondary.withOpacity(
                                isDark ? 0.15 : 0.1,
                              ),
                              theme.colorScheme.secondary.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Centered content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 140 * _pulseAnimation.value,
                                    height: 140 * _pulseAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.3),
                                          primaryColor.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Inner glow
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.2),
                                      primaryColor.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                              // Logo image
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      theme.colorScheme.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Animated app name with shimmer
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _shimmerController,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                isDark ? Colors.white : const Color(0xFF0F172A),
                                primaryColor,
                                theme.colorScheme.secondary,
                                isDark ? Colors.white : const Color(0xFF0F172A),
                              ],
                              stops: [
                                0.0,
                                (_shimmerAnimation.value - 0.2).clamp(0.0, 1.0),
                                _shimmerAnimation.value.clamp(0.0, 1.0),
                                1.0,
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Quirzy',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: Text(
                      'AI Quiz Generator',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Animated loading dots
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: _AnimatedLoadingDots(
                      controller: _dotsController,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loading text
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: Text(
                      'Getting things ready...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Center(
                  child: Text(
                    'Made with ✨ by Quirzy Team',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : const Color(0xFF94A3B8).withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLoadingDots extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _AnimatedLoadingDots({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + (sin(progress * pi) * 0.5);
            final opacity = 0.3 + (sin(progress * pi) * 0.7);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
