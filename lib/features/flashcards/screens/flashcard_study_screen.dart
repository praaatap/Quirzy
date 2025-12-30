import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late AnimationController _pulseController;
  late Animation<double> _flipAnimation;
  late Animation<double> _entranceAnimation;

  // Track card states
  final Set<int> _masteredCards = {};
  final Set<int> _reviewCards = {};

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      HapticFeedback.selectionClick();
      _entranceController.reset();
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
      _entranceController.forward();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      _entranceController.reset();
      setState(() {
        _currentIndex--;
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
    _nextCard();
  }

  void _markForReview() {
    HapticFeedback.lightImpact();
    setState(() {
      _reviewCards.add(_currentIndex);
      _masteredCards.remove(_currentIndex);
    });
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium dark theme colors
    final bgColor = isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final accentPurple = const Color(0xFF8B5CF6);
    final accentPurpleLight = const Color(0xFFa78bfa);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF71717A)
        : const Color(0xFF64748B);
    final surfaceColor = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFF1F5F9);

    if (widget.cards.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.style_outlined,
                  size: 64,
                  color: accentPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No flashcards yet',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate some flashcards to start studying',
                style: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = widget.cards[_currentIndex];
    final front =
        currentCard['front'] ?? currentCard['question'] ?? 'No question';
    final back = currentCard['back'] ?? currentCard['answer'] ?? 'No answer';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _entranceAnimation,
            child: Column(
              children: [
                // Header
                _buildHeader(
                  theme,
                  isDark,
                  textPrimary,
                  textSecondary,
                  accentPurple,
                ),

                // Progress bar
                _buildProgressBar(isDark, accentPurple, surfaceColor),

                const SizedBox(height: 16),

                // Flashcard
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _flipCard,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < -200) {
                          _nextCard();
                        } else if (details.primaryVelocity! > 200) {
                          _previousCard();
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * pi;
                          final isFront = angle < pi / 2;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: isFront
                                ? _buildFrontCard(
                                    front,
                                    isDark,
                                    textPrimary,
                                    textSecondary,
                                    accentPurple,
                                    accentPurpleLight,
                                    cardBg,
                                  )
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(pi),
                                    child: _buildBackCard(
                                      back,
                                      isDark,
                                      textPrimary,
                                      textSecondary,
                                      accentPurple,
                                      cardBg,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Action buttons (Save, Report)
                _buildActionButtons(isDark, textSecondary, surfaceColor),

                const SizedBox(height: 16),

                // Bottom buttons (Needs Review, Got it!)
                _buildBottomButtons(
                  isDark,
                  accentPurple,
                  textPrimary,
                  surfaceColor,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color accentPurple,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                size: 20,
              ),
            ),
          ),

          // Title section
          Expanded(
            child: Column(
              children: [
                Text(
                  'STUDYING',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: accentPurple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz_rounded, color: textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    bool isDark,
    Color accentPurple,
    Color surfaceColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF64748B),
                ),
              ),
              Text(
                '${_currentIndex + 1} / ${widget.cards.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Segmented progress bar
          Row(
            children: List.generate(widget.cards.length, (index) {
              final isCompleted = index <= _currentIndex;
              final isMastered = _masteredCards.contains(index);
              final isReview = _reviewCards.contains(index);

              Color segmentColor;
              if (isMastered) {
                segmentColor = const Color(0xFF22C55E);
              } else if (isReview) {
                segmentColor = const Color(0xFFF59E0B);
              } else if (isCompleted) {
                segmentColor = accentPurple;
              } else {
                segmentColor = surfaceColor;
              }

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < widget.cards.length - 1 ? 4 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: segmentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(
    String front,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color accentPurple,
    Color accentPurpleLight,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentPurple.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Gradient background with wave pattern
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1E1E2E),
                          const Color(0xFF2D1F4E),
                          const Color(0xFF1A1A2E),
                        ]
                      : [
                          const Color(0xFFE0E7FF),
                          const Color(0xFFC7D2FE),
                          const Color(0xFFE0E7FF),
                        ],
                ),
              ),
            ),

            // Wave pattern overlay
            CustomPaint(
              size: Size.infinite,
              painter: _WavePatternPainter(
                color: accentPurple.withOpacity(isDark ? 0.3 : 0.2),
              ),
            ),

            // Sound button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  size: 20,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Question badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentPurple.withOpacity(0.3)),
                    ),
                    child: Text(
                      'QUESTION',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: accentPurpleLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Question text
                  Text(
                    front,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Tap to flip hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to flip',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(
    String back,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color accentPurple,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A2E1E),
                          const Color(0xFF1F3D2A),
                          const Color(0xFF1A2E1A),
                        ]
                      : [
                          const Color(0xFFDCFCE7),
                          const Color(0xFFBBF7D0),
                          const Color(0xFFDCFCE7),
                        ],
                ),
              ),
            ),

            // Wave pattern overlay
            CustomPaint(
              size: Size.infinite,
              painter: _WavePatternPainter(
                color: const Color(0xFF22C55E).withOpacity(isDark ? 0.3 : 0.2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Answer badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'ANSWER',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Answer text
                  Text(
                    back,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Tap to flip hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to flip back',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    bool isDark,
    Color textSecondary,
    Color surfaceColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.bookmark_outline_rounded,
            label: 'SAVE',
            isDark: isDark,
            surfaceColor: surfaceColor,
            textColor: textSecondary,
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Card saved!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 32),
          _ActionButton(
            icon: Icons.flag_outlined,
            label: 'REPORT',
            isDark: isDark,
            surfaceColor: surfaceColor,
            textColor: textSecondary,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
    bool isDark,
    Color accentPurple,
    Color textPrimary,
    Color surfaceColor,
  ) {
    final isLastCard = _currentIndex >= widget.cards.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Needs Review button
          Expanded(
            child: GestureDetector(
              onTap: _markForReview,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      color: const Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Needs Review',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Got it! button
          Expanded(
            child: GestureDetector(
              onTap: isLastCard
                  ? () => Navigator.pop(context)
                  : _markAsMastered,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentPurple, accentPurple.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLastCard ? 'Done' : 'Got it!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color surfaceColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.surfaceColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePatternPainter extends CustomPainter {
  final Color color;

  _WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create multiple wave layers
    for (int layer = 0; layer < 3; layer++) {
      final yOffset = size.height * 0.3 + (layer * 30);
      final amplitude = 20.0 + (layer * 10);

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            sin((x / size.width) * 2 * pi + (layer * 0.5)) * amplitude;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(
        path,
        paint..color = color.withOpacity(0.1 + (layer * 0.05)),
      );
      path.reset();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
