import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/flashcards/services/flashcard_service.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final int setId;
  final String title;
  final List<Map<String, dynamic>> cards;

  const FlashcardStudyScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.cards,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;

  void _markCard(bool known) {
    HapticFeedback.mediumImpact();

    final cardId = widget.cards[_currentIndex]['id'];
    if (cardId != null) {
      FlashcardService.updateCardProgress(cardId, known);
    }

    setState(() {
      if (known) {
        _knownCount++;
      } else {
        _unknownCount++;
      }
    });

    _goToNextCard();
  }

  void _goToNextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _showCompletionDialog() {
    final total = widget.cards.length;
    final percentage = total > 0 ? ((_knownCount / total) * 100).round() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.celebration_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Session Complete!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text('mastered', style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(
                  icon: Icons.check_circle,
                  label: 'Known',
                  value: '$_knownCount',
                  color: Colors.green,
                ),
                _StatChip(
                  icon: Icons.refresh,
                  label: 'Review',
                  value: '$_unknownCount',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _knownCount = 0;
                _unknownCount = 0;
              });
            },
            child: Text(
              'Study Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
    final card = widget.cards[_currentIndex];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Background gradient orbs
          _BackgroundDecoration(isDark: isDark),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _GlassButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_currentIndex + 1} of ${widget.cards.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ((_currentIndex + 1) / widget.cards.length),
                      backgroundColor: Colors.purple.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(Colors.purple),
                      minHeight: 6,
                    ),
                  ),
                ),

                // Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < -200) {
                          _goToNextCard();
                        } else if (details.primaryVelocity! > 200) {
                          _goToPreviousCard();
                        }
                      },
                      child: FlipCard(
                        key: ValueKey(_currentIndex),
                        direction: FlipDirection.HORIZONTAL,
                        speed: 400,
                        onFlip: () => HapticFeedback.lightImpact(),
                        front: _GlassCard(
                          text: card['front'] ?? 'No content',
                          label: 'TAP TO FLIP',
                          isFront: true,
                          isDark: isDark,
                        ),
                        back: _GlassCard(
                          text: card['back'] ?? 'No answer',
                          label: 'ANSWER',
                          isFront: false,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Still Learning',
                          color: Colors.orange,
                          onTap: () => _markCard(false),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.check_rounded,
                          label: 'Got It!',
                          color: Colors.green,
                          filled: true,
                          onTap: () => _markCard(true),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// GLASS CARD WITH BLUR
// ==========================================

class _GlassCard extends StatelessWidget {
  final String text;
  final String label;
  final bool isFront;
  final bool isDark;

  const _GlassCard({
    required this.text,
    required this.label,
    required this.isFront,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFront ? Colors.indigo : Colors.teal;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.04),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient accent
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),

              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SUPPORTING WIDGETS
// ==========================================

class _BackgroundDecoration extends StatelessWidget {
  final bool isDark;

  const _BackgroundDecoration({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black87,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: filled ? null : Border.all(color: color.withOpacity(0.3)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
