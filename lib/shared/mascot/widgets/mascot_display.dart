import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../models/mascot_enums.dart';
import '../models/mascot_info.dart';
import '../models/mascot_dialogue.dart';
import '../painters/mascot_painter_factory.dart';

class MascotDisplay extends StatefulWidget {
  final MascotCharacter character;
  final MascotMood mood;
  final MascotAnimation? animation;
  final double size;
  final bool showSpeechBubble;
  final String? customMessage;
  final bool enableInteraction;
  final VoidCallback? onTap;
  final bool autoAnimate;

  const MascotDisplay({
    super.key,
    this.character = MascotCharacter.quizzy,
    this.mood = MascotMood.idle,
    this.animation,
    this.size = 120,
    this.showSpeechBubble = false,
    this.customMessage,
    this.enableInteraction = true,
    this.onTap,
    this.autoAnimate = true,
  });

  @override
  State<MascotDisplay> createState() => _MascotDisplayState();
}

class _MascotDisplayState extends State<MascotDisplay>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _actionController;
  late AnimationController _expressionController;

  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _bounceAnimation;

  bool _isPressed = false;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.showSpeechBubble) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showBubble = true);
      });
    }
  }

  void _initializeAnimations() {
    // Idle floating animation
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Action animations (jump, wave, etc.)
    _actionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Expression changes
    _expressionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Float animation
    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Scale animation for interactions
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _actionController, curve: Curves.elasticOut),
    );

    // Rotation for wiggle
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _actionController, curve: Curves.easeInOut),
    );

    // Bounce offset
    _bounceAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -15)).animate(
          CurvedAnimation(parent: _actionController, curve: Curves.elasticOut),
        );

    // Start idle animation
    if (widget.autoAnimate) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _actionController.dispose();
    _expressionController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enableInteraction) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enableInteraction) return;
    setState(() => _isPressed = false);
    _playBounce();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _playBounce() {
    _actionController.forward(from: 0).then((_) {
      _actionController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = MascotInfo.get(widget.character);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speech Bubble
          if (_showBubble) _buildSpeechBubble(info),

          // Mascot with animations
          AnimatedBuilder(
            animation: Listenable.merge([_idleController, _actionController]),
            builder: (context, child) {
              final floatOffset = sin(_floatAnimation.value * pi) * 6;

              return Transform.translate(
                offset: Offset(0, -floatOffset) + _bounceAnimation.value,
                child: Transform.scale(
                  scale: _isPressed ? 0.95 : _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: widget.mood == MascotMood.celebrating
                        ? _rotationAnimation.value
                        : 0,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildMascot(info),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(MascotInfo info) {
    final message =
        widget.customMessage ??
        MascotDialogue.getMessage(widget.character, widget.mood);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.bottomCenter,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: widget.size * 2.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: info.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  message,
                  textAlign: TextAlign.center,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.4,
                  ),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 4),
            // Bubble pointer
            CustomPaint(
              size: const Size(16, 8),
              painter: _BubblePointer(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascot(MascotInfo info) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: info.primaryColor.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: MascotPainterFactory.getPainter(widget.character, widget.mood),
      ),
    );
  }
}

class _BubblePointer extends CustomPainter {
  final Color color;

  _BubblePointer({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
