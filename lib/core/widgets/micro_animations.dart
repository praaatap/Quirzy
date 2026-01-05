import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎯 MICRO-ANIMATIONS LIBRARY
/// Collection of premium micro-animations for quiz app

// ==========================================
// 4️⃣ ANIMATED BUTTON with shrink on tap
// ==========================================
class AnimatedTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool bounceOnSuccess;
  final Duration duration;

  const AnimatedTapButton({
    super.key,
    required this.child,
    this.onTap,
    this.bounceOnSuccess = false,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedTapButton> createState() => AnimatedTapButtonState();
}

class AnimatedTapButtonState extends State<AnimatedTapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _shouldBounce = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void triggerSuccessBounce() {
    setState(() => _shouldBounce = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _shouldBounce = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (_shouldBounce) {
      button = button
          .animate(
            onComplete: (controller) {
              controller.reset();
            },
          )
          .scale(
            duration: 400.ms,
            curve: Curves.elasticOut,
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.15, 1.15),
          );
    }

    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.onTap,
      child: button,
    );
  }
}

// ==========================================
// 2️⃣ XP INCREASE ANIMATION
// ==========================================
class AnimatedXPCounter extends StatelessWidget {
  final int startValue;
  final int endValue;
  final Duration duration;
  final TextStyle? textStyle;

  const AnimatedXPCounter({
    super.key,
    required this.startValue,
    required this.endValue,
    this.duration = const Duration(seconds: 2),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: startValue, end: endValue),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style:
              textStyle ??
              GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        );
      },
    );
  }
}

// ==========================================
// 2️⃣ XP PROGRESS BAR with smooth fill
// ==========================================
class AnimatedXPBar extends StatelessWidget {
  final double percent;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showPercentText;

  const AnimatedXPBar({
    super.key,
    required this.percent,
    this.progressColor,
    this.backgroundColor,
    this.height = 12,
    this.showPercentText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LinearPercentIndicator(
      animation: true,
      lineHeight: height,
      animationDuration: 1500,
      percent: percent.clamp(0.0, 1.0),
      center: showPercentText
          ? Text(
              '${(percent * 100).toInt()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
      barRadius: Radius.circular(height / 2),
      progressColor: progressColor ?? theme.colorScheme.primary,
      backgroundColor:
          backgroundColor ??
          (isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1)),
      curve: Curves.easeOutCubic,
    );
  }
}

// ==========================================
// 2️⃣ CIRCULAR XP PROGRESS
// ==========================================
class AnimatedCircularXP extends StatelessWidget {
  final double percent;
  final double radius;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? center;

  const AnimatedCircularXP({
    super.key,
    required this.percent,
    this.radius = 60,
    this.progressColor,
    this.backgroundColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: 8.0,
      animation: true,
      animationDuration: 1500,
      percent: percent.clamp(0.0, 1.0),
      center:
          center ??
          Text(
            '${(percent * 100).toInt()}%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: progressColor ?? theme.colorScheme.primary,
      backgroundColor:
          backgroundColor ??
          (isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1)),
      curve: Curves.easeOutCubic,
    );
  }
}

// ==========================================
// 🎉 LEVEL UP BADGE ANIMATION
// ==========================================
class LevelUpBadge extends StatelessWidget {
  final int level;
  final Color? badgeColor;

  const LevelUpBadge({super.key, required this.level, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                badgeColor ?? theme.colorScheme.primary,
                (badgeColor ?? theme.colorScheme.primary).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (badgeColor ?? theme.colorScheme.primary).withOpacity(
                  0.3,
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL UP!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Level $level',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
        )
        .fadeIn(duration: 300.ms)
        .then(delay: 2000.ms)
        .shake(hz: 2, curve: Curves.easeInOut)
        .fadeOut(duration: 500.ms);
  }
}

// ==========================================
// 🎯 PULSING GLOW ANIMATION
// ==========================================
class PulsingGlow extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;

  const PulsingGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: glowColor.withOpacity(0.3));
  }
}

// ==========================================
// ⚡ SUCCESS RIPPLE EFFECT
// ==========================================
class SuccessRipple extends StatelessWidget {
  final Widget child;

  const SuccessRipple({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .scale(
          duration: 200.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
        )
        .then()
        .scale(
          duration: 200.ms,
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
        );
  }
}

// ==========================================
// 💫 SHIMMER LOADING EFFECT
// ==========================================
class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(duration: duration, color: Colors.white.withOpacity(0.3));
  }
}
