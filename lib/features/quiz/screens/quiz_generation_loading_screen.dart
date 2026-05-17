import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A beautiful loading screen shown while AI generates quiz questions.
///
/// Features:
/// - Elegant blue gradient design
/// - Smooth wave background animations
/// - Pulsing AI icon with gradient ring
/// - Animated loading message transitions
/// - Progress dots indicator
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
  // ══════════════════════════════════════════════════════════════════════════
  // ANIMATION CONTROLLERS
  // ══════════════════════════════════════════════════════════════════════════

  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _gradientController;
  late Animation<double> _pulseAnimation;

  // ══════════════════════════════════════════════════════════════════════════
  // BLUE COLOR PALETTE
  // ══════════════════════════════════════════════════════════════════════════

  // Beautiful blue gradient palette - from light to deep blue
  static const Color _primaryBlue = Color(0xFF2563EB); // Primary Blue
  static const Color _lightBlue = Color(0xFF3B82F6); // Lighter Blue
  static const Color _skyBlue = Color(0xFF60A5FA); // Sky Blue
  static const Color _deepBlue = Color(0xFF1D4ED8); // Deep Blue
  static const Color _accentBlue = Color(0xFF93C5FD); // Accent Light Blue

  // ══════════════════════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════════════════════

  int _currentMessageIndex = 0;

  final List<String> _loadingMessages = [
    'Analyzing topic...',
    'Generating questions...',
    'Crafting answers...',
    'Adding difficulty levels...',
    'Almost ready...',
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMessageCycle();
  }

  void _initializeAnimations() {
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

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildWaveBackground(isDark),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedIcon(bgColor, isDark),
                const SizedBox(height: 48),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildSubtitle(isDark),
                const SizedBox(height: 32),
                _buildLoadingMessage(isDark),
                const SizedBox(height: 48),
                _buildProgressDots(isDark),
              ],
            ),
          ),
          _buildCancelButton(isDark),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildWaveBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BlueWavePainter(
            animationValue: _waveController.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedIcon(Color bgColor, bool isDark) {
    return ScaleTransition(
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
                    startAngle: _gradientController.value * 2 * math.pi,
                    colors: [
                      _deepBlue,
                      _primaryBlue,
                      _lightBlue,
                      _skyBlue,
                      _accentBlue,
                      _deepBlue,
                    ],
                  ),
                ),
              );
            },
          ),
          // Inner Circle (background color)
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
          ),
          // Spinning Progress Indicator
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? _skyBlue.withOpacity(0.3)
                    : _primaryBlue.withOpacity(0.2),
              ),
            ),
          ),
          // Center Icon with Blue Gradient
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryBlue, _lightBlue, _skyBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_deepBlue, _primaryBlue, _lightBlue],
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
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      widget.subtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        color: isDark ? Colors.white60 : Colors.black54,
        height: 1.5,
      ),
    );
  }

  Widget _buildLoadingMessage(bool isDark) {
    return AnimatedSwitcher(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? _primaryBlue.withOpacity(0.1)
              : _primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? _primaryBlue.withOpacity(0.2)
                : _primaryBlue.withOpacity(0.15),
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
                valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _loadingMessages[_currentMessageIndex],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? _skyBlue : _primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isActive = index <= _currentMessageIndex;

        // Calculate blue shade based on index
        final dotColor = isActive
            ? Color.lerp(_deepBlue, _skyBlue, index / 4)!
            : (isDark ? Colors.white12 : _primaryBlue.withOpacity(0.15));

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: dotColor,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: dotColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildCancelButton(bool isDark) {
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: Center(
        child: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            size: 18,
            color: isDark ? Colors.white30 : _primaryBlue.withOpacity(0.4),
          ),
          label: Text(
            'Cancel',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white30 : _primaryBlue.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTER - BLUE WAVE BACKGROUND
// ══════════════════════════════════════════════════════════════════════════════

class _BlueWavePainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  // Blue color palette for waves
  static const List<Color> _waveColors = [
    Color(0xFF1E40AF), // Dark Blue
    Color(0xFF2563EB), // Primary Blue
    Color(0xFF3B82F6), // Light Blue
    Color(0xFF60A5FA), // Sky Blue
    Color(0xFF93C5FD), // Accent Blue
    Color(0xFFBFDBFE), // Very Light Blue
  ];

  _BlueWavePainter({required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw flowing blue blobs
    for (int i = 0; i < 6; i++) {
      final color = _waveColors[i];
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

      final blobCenter = center + Offset(dx, dy - 50);

      // Pulsing size
      final sizePulse =
          math.sin((animationValue * 2 * math.pi * 1.2) + phase) * 25.0;
      final radius = 80.0 + (i * 20.0) + sizePulse;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(isDark ? 0.20 : 0.15),
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
        ..color = _waveColors[i % _waveColors.length].withOpacity(
          isDark ? 0.08 : 0.05,
        )
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.drawCircle(cornerPositions[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
