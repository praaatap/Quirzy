import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// ============================================================================
// QUIRZY MASCOT SYSTEM V2.0 - PRODUCTION GRADE
// Multiple Characters | Rich Animations | User Customization
// ============================================================================

/// Mascot state provider
final mascotProvider = NotifierProvider<MascotNotifier, MascotCharacter>(
  MascotNotifier.new,
);

class MascotNotifier extends Notifier<MascotCharacter> {
  @override
  MascotCharacter build() {
    // Determine initial state (synchronous part)
    // We defer the async load to after build or handle it via a loading state if needed.
    // For simplicity, we start with default and update when prefs load.
    _loadMascot();
    return MascotCharacter.quizzy;
  }

  Future<void> _loadMascot() async {
    final character = await MascotPreferences.getSelected();
    state = character;
  }

  Future<void> setMascot(MascotCharacter character) async {
    state = character;
    await MascotPreferences.setSelected(character);
  }
}

/// Available mascot characters
enum MascotCharacter {
  quizzy, // 🦉 The wise owl - Smart, scholarly
  sparky, // 🦊 The clever fox - Quick, energetic
  byte, // 🤖 The friendly robot - Tech-savvy, helpful
  whiskers, // 🐱 The curious cat - Playful, curious
}

/// Mascot mood/expression states
enum MascotMood {
  idle, // Default resting state
  happy, // Joyful expression
  celebrating, // Victory dance
  encouraging, // Motivating user
  thinking, // Processing/loading
  confused, // Wrong answer
  sad, // Poor performance
  sleeping, // Inactive/idle for long
  waving, // Greeting user
  excited, // New achievement
  proud, // User did well
  studying, // Reading/learning
}

/// Animation types
enum MascotAnimation {
  bounce, // Simple bounce
  wave, // Waving hand/wing
  dance, // Happy dance
  spin, // Quick spin
  nod, // Nodding yes
  shake, // Shaking no
  float, // Floating effect
  pulse, // Glowing pulse
  jump, // Jump up
  wiggle, // Side wiggle
}

/// Mascot character details
class MascotInfo {
  final MascotCharacter character;
  final String name;
  final String description;
  final String personality;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData fallbackIcon;

  const MascotInfo({
    required this.character,
    required this.name,
    required this.description,
    required this.personality,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.fallbackIcon,
  });

  static const Map<MascotCharacter, MascotInfo> all = {
    MascotCharacter.quizzy: MascotInfo(
      character: MascotCharacter.quizzy,
      name: 'Quizzy',
      description: 'The Wise Owl',
      personality: 'Scholarly, patient, and full of knowledge',
      primaryColor: Color(0xFF5B13EC),
      secondaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFFFFD700),
      fallbackIcon: Icons.auto_awesome,
    ),
    MascotCharacter.sparky: MascotInfo(
      character: MascotCharacter.sparky,
      name: 'Sparky',
      description: 'The Clever Fox',
      personality: 'Quick-witted, energetic, and always ready',
      primaryColor: Color(0xFFFF6B35),
      secondaryColor: Color(0xFFFFB347),
      accentColor: Color(0xFFFFE4B5),
      fallbackIcon: Icons.bolt,
    ),
    MascotCharacter.byte: MascotInfo(
      character: MascotCharacter.byte,
      name: 'Byte',
      description: 'The Friendly Robot',
      personality: 'Helpful, precise, and always learning',
      primaryColor: Color(0xFF00D4FF),
      secondaryColor: Color(0xFF00B4D8),
      accentColor: Color(0xFF90E0EF),
      fallbackIcon: Icons.smart_toy,
    ),
    MascotCharacter.whiskers: MascotInfo(
      character: MascotCharacter.whiskers,
      name: 'Whiskers',
      description: 'The Curious Cat',
      personality: 'Playful, curious, and encouraging',
      primaryColor: Color(0xFFFF69B4),
      secondaryColor: Color(0xFFFFB6C1),
      accentColor: Color(0xFFFFE4E1),
      fallbackIcon: Icons.pets,
    ),
  };

  static MascotInfo get(MascotCharacter character) => all[character]!;
}

/// Motivational messages organized by context
class MascotDialogue {
  static final Random _random = Random();

  // Welcome messages per character
  static const Map<MascotCharacter, List<String>> welcomeMessages = {
    MascotCharacter.quizzy: [
      "Hoot hoot! Ready to learn? 🦉",
      "Knowledge awaits, my friend! 📚",
      "Let's make you wiser today! ✨",
      "Another day, another lesson! 🎓",
    ],
    MascotCharacter.sparky: [
      "Hey! Let's go fast! ⚡",
      "Ready to crush some quizzes? 🔥",
      "Time to show what you got! 💪",
      "Quick thinking starts now! 🚀",
    ],
    MascotCharacter.byte: [
      "Systems online. Ready to learn! 🤖",
      "Processing... Fun detected! 💾",
      "Let's compute some knowledge! 💡",
      "Initiating study mode... ✅",
    ],
    MascotCharacter.whiskers: [
      "Meow! Let's play and learn! 🐱",
      "I'm curious... what's today's topic? 🌟",
      "Paws up for learning! ✨",
      "Purr-fect time to study! 📖",
    ],
  };

  // Encouraging messages
  static const Map<MascotCharacter, List<String>> encouragingMessages = {
    MascotCharacter.quizzy: [
      "Wise choice, keep going! 🦉",
      "You're learning so much! 📚",
      "Every question makes you smarter! 🧠",
      "I believe in you! ✨",
    ],
    MascotCharacter.sparky: [
      "You're on fire! 🔥",
      "Keep that energy up! ⚡",
      "Unstoppable! 💪",
      "Speed and smarts! 🚀",
    ],
    MascotCharacter.byte: [
      "Processing excellence! 💾",
      "Data shows: You're amazing! 📊",
      "Optimal performance detected! ✅",
      "Keep computing! 🤖",
    ],
    MascotCharacter.whiskers: [
      "Purrr-fect answer! 🐱",
      "You're doing great, friend! 🌟",
      "So proud of you! ❤️",
      "Keep playing! 🎮",
    ],
  };

  // Celebration messages
  static const Map<MascotCharacter, List<String>> celebrationMessages = {
    MascotCharacter.quizzy: [
      "Outstanding wisdom! 🎓",
      "A true scholar! 🦉",
      "Knowledge mastered! 🏆",
      "Brilliant! 🌟",
    ],
    MascotCharacter.sparky: [
      "AMAZING! You crushed it! 🔥",
      "Lightning fast genius! ⚡",
      "Champion mode activated! 🏆",
      "You're incredible! 💪",
    ],
    MascotCharacter.byte: [
      "Achievement unlocked! 🏆",
      "Maximum score computed! 💯",
      "Error-free performance! ✅",
      "You're the best! 🤖",
    ],
    MascotCharacter.whiskers: [
      "Meow-velous! 🎉",
      "Purr-fection! 🐱",
      "You did it! ❤️",
      "Amazing human! 🌟",
    ],
  };

  // Sad/comfort messages
  static const Map<MascotCharacter, List<String>> comfortMessages = {
    MascotCharacter.quizzy: [
      "Every mistake teaches something 📚",
      "Wisdom comes from trying 🦉",
      "Let's review together ✨",
      "You'll get it next time! 💙",
    ],
    MascotCharacter.sparky: [
      "Shake it off! Try again! ⚡",
      "Speed bumps happen! 🛤️",
      "Get back up! 💪",
      "Next round is yours! 🔥",
    ],
    MascotCharacter.byte: [
      "Error logged. Retrying... 🔄",
      "Debugging in progress 💾",
      "Every bug makes you stronger 🐛",
      "System learning from mistakes ✅",
    ],
    MascotCharacter.whiskers: [
      "Don't be sad! *nuzzles* 🐱",
      "I still believe in you! ❤️",
      "Let's try again together! 🌟",
      "You're still amazing! 💕",
    ],
  };

  // Thinking/loading messages
  static const Map<MascotCharacter, List<String>> thinkingMessages = {
    MascotCharacter.quizzy: [
      "Hmm, let me think... 🤔",
      "Consulting my wisdom... 📚",
      "Processing knowledge... 🦉",
    ],
    MascotCharacter.sparky: [
      "Quick thinking... ⚡",
      "Almost there... 🔥",
      "Speed loading... 🚀",
    ],
    MascotCharacter.byte: [
      "Computing... 💾",
      "Loading data... 📊",
      "Please wait... ⏳",
    ],
    MascotCharacter.whiskers: [
      "Curious... 🐱",
      "Let me see... 👀",
      "Hmm... 🤔",
    ],
  };

  static String getMessage(MascotCharacter character, MascotMood mood) {
    List<String> messages;

    switch (mood) {
      case MascotMood.happy:
      case MascotMood.waving:
      case MascotMood.idle:
        messages = welcomeMessages[character]!;
        break;
      case MascotMood.encouraging:
      case MascotMood.studying:
        messages = encouragingMessages[character]!;
        break;
      case MascotMood.celebrating:
      case MascotMood.excited:
      case MascotMood.proud:
        messages = celebrationMessages[character]!;
        break;
      case MascotMood.sad:
      case MascotMood.confused:
        messages = comfortMessages[character]!;
        break;
      case MascotMood.thinking:
        messages = thinkingMessages[character]!;
        break;
      default:
        messages = welcomeMessages[character]!;
    }

    return messages[_random.nextInt(messages.length)];
  }
}

/// Mascot preference manager
class MascotPreferences {
  static const String _key = 'selected_mascot';

  static Future<MascotCharacter> getSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    return MascotCharacter.values[index.clamp(
      0,
      MascotCharacter.values.length - 1,
    )];
  }

  static Future<void> setSelected(MascotCharacter character) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, character.index);
  }
}

// ============================================================================
// MASCOT WIDGET - PRODUCTION GRADE
// ============================================================================

class QuirzyMascotV2 extends StatefulWidget {
  final MascotCharacter character;
  final MascotMood mood;
  final MascotAnimation? animation;
  final double size;
  final bool showSpeechBubble;
  final String? customMessage;
  final bool enableInteraction;
  final VoidCallback? onTap;
  final bool autoAnimate;

  const QuirzyMascotV2({
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
  State<QuirzyMascotV2> createState() => _QuirzyMascotV2State();
}

class _QuirzyMascotV2State extends State<QuirzyMascotV2>
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
        painter: _MascotPainterV2(
          character: widget.character,
          mood: widget.mood,
          info: info,
        ),
      ),
    );
  }
}

/// Speech bubble pointer painter
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

/// Production-grade mascot painter
class _MascotPainterV2 extends CustomPainter {
  final MascotCharacter character;
  final MascotMood mood;
  final MascotInfo info;

  _MascotPainterV2({
    required this.character,
    required this.mood,
    required this.info,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (character) {
      case MascotCharacter.quizzy:
        _paintOwl(canvas, size);
        break;
      case MascotCharacter.sparky:
        _paintFox(canvas, size);
        break;
      case MascotCharacter.byte:
        _paintRobot(canvas, size);
        break;
      case MascotCharacter.whiskers:
        _paintCat(canvas, size);
        break;
    }
  }

  // ========== QUIZZY THE OWL ==========
  void _paintOwl(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Body
    final bodyGradient = RadialGradient(
      colors: [info.secondaryColor, info.primaryColor],
      stops: const [0.3, 1.0],
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = bodyGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    // Belly
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.15),
        width: radius * 1.2,
        height: radius * 1.0,
      ),
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Eyes
    _paintOwlEyes(canvas, center, radius);

    // Beak
    _paintBeak(canvas, center, radius, const Color(0xFFF59E0B));

    // Graduation cap
    _paintGraduationCap(canvas, center, radius);

    // Wings
    _paintWings(canvas, center, radius, info.primaryColor.withOpacity(0.8));

    // Cheeks
    if (mood != MascotMood.sad) {
      _paintCheeks(canvas, center, radius);
    }
  }

  void _paintOwlEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy - radius * 0.1;
    final eyeSpacing = radius * 0.35;
    final eyeRadius = radius * 0.25;

    // Left eye
    _paintEye(canvas, Offset(center.dx - eyeSpacing, eyeY), eyeRadius, true);

    // Right eye
    _paintEye(canvas, Offset(center.dx + eyeSpacing, eyeY), eyeRadius, false);
  }

  // ========== SPARKY THE FOX ==========
  void _paintFox(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Face shape (slightly pointed)
    final facePath = Path();
    facePath.moveTo(center.dx, center.dy - radius * 0.9);
    facePath.quadraticBezierTo(
      center.dx + radius * 1.1,
      center.dy - radius * 0.3,
      center.dx + radius * 0.8,
      center.dy + radius * 0.5,
    );
    facePath.quadraticBezierTo(
      center.dx + radius * 0.4,
      center.dy + radius * 0.9,
      center.dx,
      center.dy + radius * 0.85,
    );
    facePath.quadraticBezierTo(
      center.dx - radius * 0.4,
      center.dy + radius * 0.9,
      center.dx - radius * 0.8,
      center.dy + radius * 0.5,
    );
    facePath.quadraticBezierTo(
      center.dx - radius * 1.1,
      center.dy - radius * 0.3,
      center.dx,
      center.dy - radius * 0.9,
    );

    // Orange gradient
    final foxGradient = RadialGradient(
      colors: [info.secondaryColor, info.primaryColor],
      center: const Alignment(0, -0.3),
    );
    canvas.drawPath(
      facePath,
      Paint()
        ..shader = foxGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    // White muzzle
    final muzzlePath = Path();
    muzzlePath.moveTo(center.dx - radius * 0.4, center.dy + radius * 0.1);
    muzzlePath.quadraticBezierTo(
      center.dx,
      center.dy + radius * 0.7,
      center.dx + radius * 0.4,
      center.dy + radius * 0.1,
    );
    muzzlePath.quadraticBezierTo(
      center.dx,
      center.dy + radius * 0.3,
      center.dx - radius * 0.4,
      center.dy + radius * 0.1,
    );
    canvas.drawPath(muzzlePath, Paint()..color = Colors.white);

    // Ears
    _paintFoxEars(canvas, center, radius);

    // Eyes
    _paintFoxEyes(canvas, center, radius);

    // Nose
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.35),
        width: radius * 0.2,
        height: radius * 0.15,
      ),
      Paint()..color = const Color(0xFF2D1B0E),
    );
  }

  void _paintFoxEars(Canvas canvas, Offset center, double radius) {
    final earPaint = Paint()..color = info.primaryColor;
    final innerEarPaint = Paint()..color = info.accentColor;

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
      ..lineTo(center.dx - radius * 0.9, center.dy - radius * 1.2)
      ..lineTo(center.dx - radius * 0.3, center.dy - radius * 0.6);
    canvas.drawPath(leftEarPath, earPaint);

    // Left inner ear
    final leftInnerPath = Path()
      ..moveTo(center.dx - radius * 0.55, center.dy - radius * 0.55)
      ..lineTo(center.dx - radius * 0.75, center.dy - radius * 1.0)
      ..lineTo(center.dx - radius * 0.4, center.dy - radius * 0.6);
    canvas.drawPath(leftInnerPath, innerEarPaint);

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.6, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.9, center.dy - radius * 1.2)
      ..lineTo(center.dx + radius * 0.3, center.dy - radius * 0.6);
    canvas.drawPath(rightEarPath, earPaint);

    // Right inner ear
    final rightInnerPath = Path()
      ..moveTo(center.dx + radius * 0.55, center.dy - radius * 0.55)
      ..lineTo(center.dx + radius * 0.75, center.dy - radius * 1.0)
      ..lineTo(center.dx + radius * 0.4, center.dy - radius * 0.6);
    canvas.drawPath(rightInnerPath, innerEarPaint);
  }

  void _paintFoxEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy - radius * 0.1;
    final eyeSpacing = radius * 0.35;
    final eyeRadius = radius * 0.18;

    _paintEye(canvas, Offset(center.dx - eyeSpacing, eyeY), eyeRadius, true);
    _paintEye(canvas, Offset(center.dx + eyeSpacing, eyeY), eyeRadius, false);
  }

  // ========== BYTE THE ROBOT ==========
  void _paintRobot(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Head (rounded rectangle)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 1.8),
      Radius.circular(radius * 0.4),
    );

    // Metallic gradient
    final robotGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        info.secondaryColor,
        info.primaryColor,
        info.primaryColor.withOpacity(0.8),
      ],
    );
    canvas.drawRRect(
      headRect,
      Paint()..shader = robotGradient.createShader(headRect.outerRect),
    );

    // Screen/face area
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.1),
        width: radius * 1.5,
        height: radius * 1.2,
      ),
      Radius.circular(radius * 0.2),
    );
    canvas.drawRRect(screenRect, Paint()..color = const Color(0xFF0A1628));

    // Antenna
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.9),
      Offset(center.dx, center.dy - radius * 1.3),
      Paint()
        ..color = info.primaryColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 1.35),
      radius * 0.12,
      Paint()..color = const Color(0xFF00FF88),
    );

    // Robot eyes (LED style)
    _paintRobotEyes(canvas, center, radius);

    // Mouth (LED line)
    _paintRobotMouth(canvas, center, radius);
  }

  void _paintRobotEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy;
    final eyeSpacing = radius * 0.4;
    final eyeSize = radius * 0.25;

    // Glowing effect
    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        Offset(center.dx - eyeSpacing, eyeY),
        eyeSize + i * 3,
        Paint()..color = info.accentColor.withOpacity(0.1),
      );
      canvas.drawCircle(
        Offset(center.dx + eyeSpacing, eyeY),
        eyeSize + i * 3,
        Paint()..color = info.accentColor.withOpacity(0.1),
      );
    }

    // Main eyes
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      eyeSize,
      Paint()..color = mood == MascotMood.sad ? Colors.red : info.accentColor,
    );
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      eyeSize,
      Paint()..color = mood == MascotMood.sad ? Colors.red : info.accentColor,
    );

    // Highlights
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing - eyeSize * 0.2, eyeY - eyeSize * 0.2),
      eyeSize * 0.3,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing - eyeSize * 0.2, eyeY - eyeSize * 0.2),
      eyeSize * 0.3,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
  }

  void _paintRobotMouth(Canvas canvas, Offset center, double radius) {
    final mouthY = center.dy + radius * 0.5;
    final mouthWidth = radius * 0.6;

    final mouthColor =
        mood == MascotMood.happy || mood == MascotMood.celebrating
        ? const Color(0xFF00FF88)
        : info.accentColor;

    // Smile or straight line based on mood
    if (mood == MascotMood.happy || mood == MascotMood.celebrating) {
      final smilePath = Path()
        ..moveTo(center.dx - mouthWidth, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.2,
          center.dx + mouthWidth,
          mouthY,
        );
      canvas.drawPath(
        smilePath,
        Paint()
          ..color = mouthColor
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawLine(
        Offset(center.dx - mouthWidth, mouthY),
        Offset(center.dx + mouthWidth, mouthY),
        Paint()
          ..color = mouthColor
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ========== WHISKERS THE CAT ==========
  void _paintCat(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Head
    final catGradient = RadialGradient(
      colors: [info.secondaryColor, info.primaryColor],
      center: const Alignment(0, -0.3),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = catGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    // Ears
    _paintCatEars(canvas, center, radius);

    // Inner face (lighter)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.1),
        width: radius * 1.4,
        height: radius * 1.1,
      ),
      Paint()..color = info.accentColor,
    );

    // Eyes
    _paintCatEyes(canvas, center, radius);

    // Nose
    final nosePath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.15)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.3)
      ..lineTo(center.dx + radius * 0.1, center.dy + radius * 0.3)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = info.primaryColor);

    // Whiskers
    _paintWhiskers(canvas, center, radius);

    // Mouth
    _paintCatMouth(canvas, center, radius);
  }

  void _paintCatEars(Canvas canvas, Offset center, double radius) {
    final earPaint = Paint()..color = info.primaryColor;
    final innerEarPaint = Paint()..color = info.accentColor;

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.5)
      ..lineTo(center.dx - radius * 0.5, center.dy - radius * 1.1)
      ..lineTo(center.dx - radius * 0.2, center.dy - radius * 0.6);
    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(
      leftEarPath,
      Paint()
        ..color = innerEarPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.7, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.5, center.dy - radius * 1.1)
      ..lineTo(center.dx + radius * 0.2, center.dy - radius * 0.6);
    canvas.drawPath(rightEarPath, earPaint);
    canvas.drawPath(
      rightEarPath,
      Paint()
        ..color = innerEarPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }

  void _paintCatEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy - radius * 0.05;
    final eyeSpacing = radius * 0.35;
    final eyeRadius = radius * 0.22;

    // Eye whites
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - eyeSpacing, eyeY),
        width: eyeRadius * 2,
        height: eyeRadius * 2.2,
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + eyeSpacing, eyeY),
        width: eyeRadius * 2,
        height: eyeRadius * 2.2,
      ),
      Paint()..color = Colors.white,
    );

    // Pupils (cat-style vertical)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - eyeSpacing, eyeY),
        width: eyeRadius * 0.5,
        height: eyeRadius * 1.5,
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + eyeSpacing, eyeY),
        width: eyeRadius * 0.5,
        height: eyeRadius * 1.5,
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Highlights
    canvas.drawCircle(
      Offset(center.dx - eyeSpacing - eyeRadius * 0.3, eyeY - eyeRadius * 0.3),
      eyeRadius * 0.25,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(center.dx + eyeSpacing - eyeRadius * 0.3, eyeY - eyeRadius * 0.3),
      eyeRadius * 0.25,
      Paint()..color = Colors.white,
    );
  }

  void _paintWhiskers(Canvas canvas, Offset center, double radius) {
    final whiskerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final whiskerY = center.dy + radius * 0.25;

    // Left whiskers
    canvas.drawLine(
      Offset(center.dx - radius * 0.3, whiskerY),
      Offset(center.dx - radius * 0.9, whiskerY - radius * 0.1),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.3, whiskerY + radius * 0.1),
      Offset(center.dx - radius * 0.9, whiskerY + radius * 0.15),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(center.dx + radius * 0.3, whiskerY),
      Offset(center.dx + radius * 0.9, whiskerY - radius * 0.1),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.3, whiskerY + radius * 0.1),
      Offset(center.dx + radius * 0.9, whiskerY + radius * 0.15),
      whiskerPaint,
    );
  }

  void _paintCatMouth(Canvas canvas, Offset center, double radius) {
    final mouthPaint = Paint()
      ..color = info.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthY = center.dy + radius * 0.35;

    // W-shaped cat mouth
    final mouthPath = Path()
      ..moveTo(center.dx - radius * 0.15, mouthY)
      ..quadraticBezierTo(
        center.dx - radius * 0.08,
        mouthY + radius * 0.1,
        center.dx,
        mouthY,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.08,
        mouthY + radius * 0.1,
        center.dx + radius * 0.15,
        mouthY,
      );

    canvas.drawPath(mouthPath, mouthPaint);
  }

  // ========== SHARED PAINTING METHODS ==========

  void _paintEye(Canvas canvas, Offset center, double radius, bool isLeft) {
    // White of eye
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Pupil
    Offset pupilOffset = center;
    if (mood == MascotMood.thinking) {
      pupilOffset = Offset(center.dx + (isLeft ? -2 : 2), center.dy - 2);
    } else if (mood == MascotMood.sad) {
      pupilOffset = Offset(center.dx, center.dy + 2);
    }

    canvas.drawCircle(
      pupilOffset,
      radius * 0.5,
      Paint()..color = const Color(0xFF1E293B),
    );

    // Highlight
    canvas.drawCircle(
      Offset(pupilOffset.dx - radius * 0.15, pupilOffset.dy - radius * 0.15),
      radius * 0.2,
      Paint()..color = Colors.white,
    );
  }

  void _paintBeak(Canvas canvas, Offset center, double radius, Color color) {
    final beakPath = Path()
      ..moveTo(center.dx - radius * 0.12, center.dy + radius * 0.2)
      ..lineTo(center.dx, center.dy + radius * 0.4)
      ..lineTo(center.dx + radius * 0.12, center.dy + radius * 0.2)
      ..close();

    canvas.drawPath(beakPath, Paint()..color = color);
  }

  void _paintGraduationCap(Canvas canvas, Offset center, double radius) {
    final capY = center.dy - radius * 0.85;

    // Cap top
    final capPath = Path()
      ..moveTo(center.dx - radius * 0.8, capY)
      ..lineTo(center.dx + radius * 0.8, capY)
      ..lineTo(center.dx + radius * 0.6, capY - radius * 0.15)
      ..lineTo(center.dx - radius * 0.6, capY - radius * 0.15)
      ..close();

    canvas.drawPath(capPath, Paint()..color = const Color(0xFF1E293B));

    // Button
    canvas.drawCircle(
      Offset(center.dx, capY - radius * 0.05),
      radius * 0.08,
      Paint()..color = info.accentColor,
    );

    // Tassel
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + radius * 0.4, capY - radius * 0.1)
        ..quadraticBezierTo(
          center.dx + radius * 0.8,
          capY + radius * 0.2,
          center.dx + radius * 0.6,
          capY + radius * 0.5,
        ),
      Paint()
        ..color = info.accentColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.6, capY + radius * 0.5),
      radius * 0.06,
      Paint()..color = info.accentColor,
    );
  }

  void _paintWings(Canvas canvas, Offset center, double radius, Color color) {
    // Left wing
    final leftWingPath = Path()
      ..moveTo(center.dx - radius * 0.75, center.dy)
      ..quadraticBezierTo(
        center.dx - radius * 1.1,
        center.dy + radius * 0.3,
        center.dx - radius * 0.6,
        center.dy + radius * 0.6,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.5,
        center.dy + radius * 0.3,
        center.dx - radius * 0.75,
        center.dy,
      );
    canvas.drawPath(leftWingPath, Paint()..color = color);

    // Right wing
    final rightWingPath = Path()
      ..moveTo(center.dx + radius * 0.75, center.dy)
      ..quadraticBezierTo(
        center.dx + radius * 1.1,
        center.dy + radius * 0.3,
        center.dx + radius * 0.6,
        center.dy + radius * 0.6,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.5,
        center.dy + radius * 0.3,
        center.dx + radius * 0.75,
        center.dy,
      );
    canvas.drawPath(rightWingPath, Paint()..color = color);
  }

  void _paintCheeks(Canvas canvas, Offset center, double radius) {
    final cheekColor = const Color(0xFFFF6B9D).withOpacity(0.4);
    final cheekY = center.dy + radius * 0.1;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.55, cheekY),
        width: radius * 0.25,
        height: radius * 0.15,
      ),
      Paint()..color = cheekColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.55, cheekY),
        width: radius * 0.25,
        height: radius * 0.15,
      ),
      Paint()..color = cheekColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainterV2 oldDelegate) {
    return oldDelegate.character != character || oldDelegate.mood != mood;
  }
}

// ============================================================================
// MASCOT SELECTOR WIDGET
// ============================================================================

class MascotSelector extends ConsumerWidget {
  const MascotSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mascotProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose Your Study Buddy',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a companion to help you learn!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),

        // Mascot grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: MascotCharacter.values.length,
          itemBuilder: (context, index) {
            final character = MascotCharacter.values[index];
            final info = MascotInfo.get(character);
            final isSelected = character == selected;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(mascotProvider.notifier).setMascot(character);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? (isSelected
                            ? info.primaryColor.withOpacity(0.2)
                            : const Color(0xFF1A1A1A))
                      : (isSelected
                            ? info.primaryColor.withOpacity(0.1)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? info.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: info.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        QuirzyMascotV2(
                          character: character,
                          mood: isSelected ? MascotMood.happy : MascotMood.idle,
                          size: 80,
                          autoAnimate: isSelected,
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: info.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? info.primaryColor
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// FLOATING COMPANION WIDGET
// ============================================================================

class FloatingCompanion extends ConsumerStatefulWidget {
  final Alignment alignment;
  final VoidCallback? onTap;

  const FloatingCompanion({
    super.key,
    this.alignment = Alignment.bottomRight,
    this.onTap,
  });

  @override
  ConsumerState<FloatingCompanion> createState() => _FloatingCompanionState();
}

class _FloatingCompanionState extends ConsumerState<FloatingCompanion> {
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    // Show message after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showMessage = true);
    });
  }

  void _openMascotSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: const MascotSelector(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(mascotProvider);

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _openMascotSelector();
          },
          child: QuirzyMascotV2(
            character: character,
            mood: MascotMood.happy,
            size: 80,
            showSpeechBubble: _showMessage,
            enableInteraction: true,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showMessage = !_showMessage);
              widget.onTap?.call();
            },
          ),
        ),
      ),
    );
  }
}
