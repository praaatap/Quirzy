import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// 3️⃣ LEVEL UP MOMENT (BIG dopamine hit 🎉)
/// Confetti burst + Badge animation + Haptic feedback

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final int xpEarned;
  final VoidCallback? onComplete;
  final bool showConfetti;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    required this.xpEarned,
    this.onComplete,
    this.showConfetti = true,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation> {
  late ConfettiController _confettiController;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Start confetti
    if (widget.showConfetti) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _confettiController.play();
        }
      });
    }

    // Show content
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });

    // Additional haptic feedback during animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) HapticFeedback.mediumImpact();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) HapticFeedback.lightImpact();
    });

    // Complete callback
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Confetti
            if (widget.showConfetti) ...[
              // Left confetti
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 4,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
              ),
              // Right confetti
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3 * pi / 4,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.2,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
              ),
              // Center confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.15,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
              ),
            ],

            // Main content
            Center(
              child: _showContent
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trophy/Badge Icon
                        Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 80,
                                color: Colors.white,
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
                            .then(delay: 200.ms)
                            .shake(
                              hz: 3,
                              curve: Curves.easeInOut,
                              rotation: 0.05,
                            ),

                        const SizedBox(height: 32),

                        // "LEVEL UP!" text
                        Text(
                              'LEVEL UP!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms)
                            .slideY(begin: 0.3, end: 0, curve: Curves.easeOut)
                            .then(delay: 100.ms)
                            .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.5),
                            ),

                        const SizedBox(height: 16),

                        // New level
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.3),
                                    theme.colorScheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Level ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    '${widget.newLevel}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 400.ms)
                            .scale(
                              delay: 500.ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            ),

                        const SizedBox(height: 24),

                        // XP earned
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+${widget.xpEarned} XP',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 400.ms)
                            .slideY(
                              delay: 700.ms,
                              begin: 0.5,
                              end: 0,
                              curve: Curves.easeOut,
                            ),

                        const SizedBox(height: 40),

                        // Motivational text
                        Text(
                          'Keep up the great work! 🎉',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// COMPACT LEVEL UP NOTIFICATION
// ==========================================
class CompactLevelUpNotification extends StatelessWidget {
  final int newLevel;

  const CompactLevelUpNotification({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL UP!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Level $newLevel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
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
        .scale(duration: 500.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms)
        .then(delay: 2000.ms)
        .fadeOut(duration: 500.ms);
  }
}

// ==========================================
// XP GAIN POPUP
// ==========================================
class XPGainPopup extends StatelessWidget {
  final int xpAmount;
  final String reason;

  const XPGainPopup({
    super.key,
    required this.xpAmount,
    this.reason = 'Quiz Completed',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade600, Colors.amber.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$xpAmount XP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    reason,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms)
        .then(delay: 1500.ms)
        .slideY(begin: 0, end: -1, duration: 300.ms)
        .fadeOut(duration: 300.ms);
  }
}
