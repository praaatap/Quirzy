import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final dynamic setId;
  final String title;
  final List<Map<String, dynamic>> cards;

  const FlashcardStudyScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.cards,
  });

  @override
  ConsumerState<FlashcardStudyScreen> createState() =>
      _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late AnimationController _entranceController;
  late Animation<double> _flipAnimation;
  late Animation<double> _entranceAnimation;

  final FlutterTts flutterTts = FlutterTts();

  // Track card states
  final Set<int> _masteredCards = {};
  final Set<int> _reviewCards = {};

  static const primaryColor = Color(0xFF5B13EC);

  @override
  void initState() {
    super.initState();
    _initTTS();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceController.forward();
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _entranceController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      HapticFeedback.lightImpact();
      _entranceController.reset();
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
      _entranceController.forward();
    }
  }

  void _markAsMastered() {
    HapticFeedback.mediumImpact();
    setState(() {
      _masteredCards.add(_currentIndex);
      _reviewCards.remove(_currentIndex);
    });
    if (_currentIndex < widget.cards.length - 1) {
      _nextCard();
    } else {
      _showCompletionDialog();
    }
  }

  void _markForReview() {
    HapticFeedback.mediumImpact();
    setState(() {
      _reviewCards.add(_currentIndex);
      _masteredCards.remove(_currentIndex);
    });
    if (_currentIndex < widget.cards.length - 1) {
      _nextCard();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Set Completed!",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "You've reviewed all cards.",
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text(
              "Finish",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium Theme Colors
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF664C9A);

    if (widget.cards.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: textMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'No cards available.',
            style: GoogleFonts.plusJakartaSans(color: textSub),
          ),
        ),
      );
    }

    final currentCard = widget.cards[_currentIndex];
    final front =
        currentCard['front'] ?? currentCard['question'] ?? 'No question';
    final back = currentCard['back'] ?? currentCard['answer'] ?? 'No answer';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark, textMain, textSub, surfaceColor),

            // Progress Bar
            _buildProgressBar(isDark, surfaceColor),

            const SizedBox(height: 24),

            // Main Card Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.8, // Portrait card feel
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: FadeTransition(
                        opacity: _entranceAnimation,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            // 3D Flip Logic
                            final angle = _flipAnimation.value * pi;
                            final isFront = angle < pi / 2;

                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // Perspective
                                ..rotateY(angle),
                              child: isFront
                                  ? _buildCardSide(
                                      text: front,
                                      isFront: true,
                                      isDark: isDark,
                                      surfaceColor: surfaceColor,
                                      textColor: textMain,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(
                                          pi,
                                        ), // Correct back text reflection
                                      child: _buildCardSide(
                                        text: back,
                                        isFront: false,
                                        isDark: isDark,
                                        surfaceColor: surfaceColor,
                                        textColor: textMain,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Controls
            _buildControls(isDark, surfaceColor, textMain),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color textMain,
    Color textSub,
    Color surfaceColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(color: Colors.white.withOpacity(0.05))
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(Icons.close_rounded, color: textMain, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDYING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: primaryColor,
                  ),
                ),
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz_rounded, color: textMain),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                '${_currentIndex + 1} / ${widget.cards.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(widget.cards.length, (index) {
              final isCompleted = index <= _currentIndex;
              final isCurrent = index == _currentIndex;
              final isMastered = _masteredCards.contains(index);
              final isReview = _reviewCards.contains(index);

              Color color;
              if (isCurrent) {
                color = primaryColor;
              } else if (isMastered) {
                color = const Color(0xFF2EC4B6);
              } else if (isReview) {
                color = const Color(0xFFFF9F1C);
              } else if (isCompleted) {
                color = primaryColor.withOpacity(0.5);
              } else {
                color = primaryColor.withOpacity(
                  0.2,
                ); // Light purple placeholders
              }

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6, // Thicker pill
                  margin: EdgeInsets.only(
                    right: index < widget.cards.length - 1 ? 4 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide({
    required String text,
    required bool isFront,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
  }) {
    // Gradient Logic
    final gradient = isFront
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)]
                : [const Color(0xFFEFE9FD), Colors.white],
          )
        : null;

    final bgColor = isFront ? null : surfaceColor;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isFront
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.transparent)
              : primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Wave Pattern (Only on front or desired style)
            if (isFront)
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePatternPainter(
                    color: primaryColor.withOpacity(0.08),
                    secondaryColor: Colors.deepPurpleAccent.withOpacity(0.05),
                  ),
                ),
              ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isFront ? 'QUESTION' : 'ANSWER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26, // Larger text
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFront
                                ? Icons.touch_app_rounded
                                : Icons.replay_rounded,
                            size: 16,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFront ? 'Tap to flip' : 'Tap to flip back',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Speaker Icon (Top Right)
            Positioned(
              top: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _speak(text);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.4,
                    ), // Dark translucent pill
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(bool isDark, Color surfaceColor, Color textMain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ControlButton(
              icon: Icons.close_rounded,
              label: 'Needs Review',
              iconColor: const Color(0xFFEF4444), // Red
              onTap: _markForReview,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact(); // Satisfying click
                _markAsMastered();
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF8B5CF6,
                  ), // Bright Purple like screenshot
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Got it!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDark;
  final Color surfaceColor;
  final Color textMain;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    required this.isDark,
    required this.surfaceColor,
    required this.textMain,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePatternPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _WavePatternPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Pattern 1 (Top Wave)
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.3,
      size.width,
      size.height * 0.45,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Pattern 2 (Overlapping Wave)
    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(0, size.height * 0.25);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.6,
      size.height * 0.25,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.15,
      size.width,
      size.height * 0.3,
    );
    path2.lineTo(size.width, 0);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
