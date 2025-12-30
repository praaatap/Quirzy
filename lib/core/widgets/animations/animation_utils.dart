import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smooth page route with fade + slide transition
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Duration reverseDuration;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
    this.reverseDuration = const Duration(milliseconds: 280),
  }) : super(
         pageBuilder: (_, __, ___) => page,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
             child: SlideTransition(
               position:
                   Tween<Offset>(
                     begin: const Offset(0.02, 0),
                     end: Offset.zero,
                   ).animate(
                     CurvedAnimation(
                       parent: animation,
                       curve: Curves.easeOutCubic,
                     ),
                   ),
               child: child,
             ),
           );
         },
       );
}

/// Scale + Fade page transition
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadePageRoute({required this.page})
    : super(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      );
}

/// Staggered list item animation wrapper
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final int maxStagger;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.maxStagger = 10,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final delay =
        widget.staggerDelay * widget.index.clamp(0, widget.maxStagger);
    Future.delayed(delay, () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Pressable scale animation for buttons and cards
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final bool hapticFeedback;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.hapticFeedback = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.hapticFeedback) HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: () {
        if (widget.hapticFeedback) HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Shimmer loading effect
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        widget.baseColor ??
        (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0));
    final highlight =
        widget.highlightColor ??
        (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, highlight, base],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulse animation for attention-grabbing elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool autoStart;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.autoStart = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/// Floating animation for cards and elements
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double floatHeight;
  final Axis axis;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.floatHeight = 8,
    this.axis = Axis.vertical,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.floatHeight,
      end: widget.floatHeight,
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
        return Transform.translate(
          offset: widget.axis == Axis.vertical
              ? Offset(0, _animation.value)
              : Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animated gradient background blob
class AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double blurSigma;

  const AnimatedBlob({
    super.key,
    required this.color,
    required this.size,
    this.blurSigma = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.5), color.withOpacity(0)],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// Animated counter for numbers
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;
  final String? prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, val, child) {
        return Text('${prefix ?? ''}$val${suffix ?? ''}', style: style);
      },
    );
  }
}

/// Smooth opacity transition with scale
class SmoothAppear extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const SmoothAppear({
    super.key,
    required this.child,
    required this.visible,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: visible ? 1.0 : 0.95,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}

/// Hero-like shared element transition helper
class SharedTransitionWidget extends StatelessWidget {
  final String tag;
  final Widget child;

  const SharedTransitionWidget({
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: animation,
                child: toHeroContext.widget,
              ),
            );
          },
      child: Material(color: Colors.transparent, child: child),
    );
  }
}

/// Animated switcher with custom transition
class SmoothSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SmoothSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Glow effect container
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double spreadRadius;
  final BorderRadius? borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 20,
    this.spreadRadius = -2,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: glowRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Typing animation for text
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _typeNextChar();
  }

  void _typeNextChar() {
    if (_charIndex < widget.text.length) {
      Future.delayed(widget.charDuration, () {
        if (mounted) {
          setState(() {
            _displayText = widget.text.substring(0, _charIndex + 1);
            _charIndex++;
          });
          _typeNextChar();
        }
      });
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayText, style: widget.style);
  }
}
