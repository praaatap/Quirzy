import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Game Effects Service - Provides game-like micro-animations and haptics
/// Makes the app feel like a premium gaming experience
class GameEffectsService {
  static final GameEffectsService _instance = GameEffectsService._internal();
  factory GameEffectsService() => _instance;
  GameEffectsService._internal();

  final math.Random _random = math.Random();

  // ==========================================
  // HAPTIC FEEDBACK
  // ==========================================

  /// Light tap feedback (button press)
  void lightTap() {
    HapticFeedback.lightImpact();
  }

  /// Medium tap feedback (selection)
  void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy feedback (important action)
  void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Success vibration pattern
  void successVibration() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error vibration pattern
  void errorVibration() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Correct answer celebration haptic
  void correctAnswer() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Wrong answer haptic
  void wrongAnswer() {
    HapticFeedback.heavyImpact();
  }

  /// Rank up celebration haptic pattern
  void rankUpCelebration() {
    // Triple burst pattern
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  /// XP gain haptic
  void xpGain() {
    HapticFeedback.selectionClick();
  }

  /// Streak maintained haptic
  void streakMaintained() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }

  // ==========================================
  // SOUND EFFECTS (placeholder for future)
  // ==========================================

  // Note: Sound effects would use audioplayers package
  // For now, we rely on haptic feedback only to keep app size small

  // ==========================================
  // PARTICLE GENERATION HELPERS
  // ==========================================

  /// Generate random particle positions
  List<Offset> generateParticlePositions(int count, Size bounds) {
    return List.generate(count, (_) {
      return Offset(
        _random.nextDouble() * bounds.width,
        _random.nextDouble() * bounds.height,
      );
    });
  }

  /// Generate random colors for particles
  List<Color> generateParticleColors(int count, List<Color> baseColors) {
    return List.generate(count, (_) {
      return baseColors[_random.nextInt(baseColors.length)];
    });
  }

  /// Generate random sizes for particles
  List<double> generateParticleSizes(
    int count, {
    double min = 2,
    double max = 8,
  }) {
    return List.generate(count, (_) {
      return min + _random.nextDouble() * (max - min);
    });
  }

  // ==========================================
  // SCORE CALCULATIONS (Game Feel)
  // ==========================================

  /// Calculate combo multiplier
  double calculateComboMultiplier(int consecutiveCorrect) {
    if (consecutiveCorrect <= 0) return 1.0;
    if (consecutiveCorrect <= 2) return 1.0;
    if (consecutiveCorrect <= 5) return 1.5;
    if (consecutiveCorrect <= 10) return 2.0;
    return 2.5;
  }

  /// Calculate time bonus (faster = more points)
  int calculateTimeBonus(int secondsRemaining, int maxSeconds) {
    if (secondsRemaining <= 0) return 0;
    final ratio = secondsRemaining / maxSeconds;
    if (ratio > 0.7) return 50; // Very fast
    if (ratio > 0.4) return 25; // Fast
    if (ratio > 0.2) return 10; // Normal
    return 0;
  }

  /// Calculate perfect streak bonus
  int calculatePerfectBonus(int totalCorrect, int totalQuestions) {
    if (totalCorrect == totalQuestions && totalQuestions >= 5) {
      return 100; // Perfect score bonus
    }
    return 0;
  }

  // ==========================================
  // ANIMATION CURVES (Game Feel)
  // ==========================================

  /// Bouncy curve for success animations
  static const Curve bouncy = Curves.elasticOut;

  /// Sharp curve for errors
  static const Curve sharp = Curves.easeOutBack;

  /// Smooth curve for transitions
  static const Curve smooth = Curves.easeInOutCubic;

  /// Punchy curve for impacts
  static const Curve punchy = Curves.easeOutExpo;
}

/// Animated Score Counter Widget
class AnimatedScoreCounter extends StatelessWidget {
  final int score;
  final TextStyle? style;
  final Duration duration;

  const AnimatedScoreCounter({
    super.key,
    required this.score,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: duration,
      builder: (context, value, child) {
        return Text(value.toString(), style: style);
      },
    );
  }
}

/// Pulsing Widget for attention
class PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulsingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

/// Shake Widget for errors
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final VoidCallback? onShakeComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shake = false,
    this.onShakeComplete,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Bounce In Widget
class BounceInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const BounceInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BounceInWidget> createState() => _BounceInWidgetState();
}

class _BounceInWidgetState extends State<BounceInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Glowing Container
class GlowingContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;

  const GlowingContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 20,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<GlowingContainer> createState() => _GlowingContainerState();
}

class _GlowingContainerState extends State<GlowingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value),
                blurRadius: widget.glowRadius,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Animated Progress Bar
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color? color;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor = const Color(0xFF2A2A30),
    this.gradient,
    this.color,
    this.duration = const Duration(milliseconds: 500),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  color: gradient == null ? color : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating Action Particle
class FloatingParticle extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const FloatingParticle({
    super.key,
    required this.color,
    this.size = 6,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _yAnimation = Tween<double>(
      begin: 0,
      end: -100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 20),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
