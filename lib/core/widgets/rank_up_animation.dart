import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:quirzy/core/services/rank_service.dart';

/// Premium Rank-Up Animation Screen
/// Shows epic animation when user ranks up (like PUBG/Free Fire)
class RankUpAnimationScreen extends StatefulWidget {
  final RankUpResult rankUpResult;
  final VoidCallback? onComplete;

  const RankUpAnimationScreen({
    super.key,
    required this.rankUpResult,
    this.onComplete,
  });

  /// Show rank-up animation as a full-screen overlay
  static Future<void> show(BuildContext context, RankUpResult result) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return RankUpAnimationScreen(
            rankUpResult: result,
            onComplete: () => Navigator.of(context).pop(),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<RankUpAnimationScreen> createState() => _RankUpAnimationScreenState();
}

class _RankUpAnimationScreenState extends State<RankUpAnimationScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _shineController;

  bool _showNewRank = false;
  bool _showDetails = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Haptic feedback for epic moment
    HapticFeedback.heavyImpact();

    // Wait a moment, then show new rank with confetti
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _showNewRank = true);
    _confettiController.play();
    HapticFeedback.mediumImpact();

    // Show details
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _showDetails = true);

    // Show continue button
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _showButton = true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMajorRankUp = widget.rankUpResult.isMajorRankUp;
    final newRank = widget.rankUpResult.newRank;
    final previousRank = widget.rankUpResult.previousRank;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(newRank.glowColor).withOpacity(0.3),
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
          ),

          // Animated particles background
          if (_showNewRank)
            ...List.generate(20, (index) => _buildFloatingParticle(index)),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Color(newRank.color),
                Color(newRank.glowColor),
                Colors.white,
                Colors.amber,
              ],
              numberOfParticles: isMajorRankUp ? 50 : 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              gravity: 0.2,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // "RANK UP!" Title
                if (_showNewRank)
                  _buildRankUpTitle(isMajorRankUp)
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fade(duration: 400.ms),

                const SizedBox(height: 40),

                // Rank badges transition
                _buildRankTransition(previousRank, newRank),

                const SizedBox(height: 40),

                // Details section
                if (_showDetails)
                  _buildDetailsSection()
                      .animate()
                      .fade(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                const Spacer(flex: 2),

                // Continue button
                if (_showButton)
                  _buildContinueButton()
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.5, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankUpTitle(bool isMajorRankUp) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: isMajorRankUp
                  ? [Colors.amber, Colors.orange, Colors.amber]
                  : [Colors.white, Colors.white70, Colors.white],
            ).createShader(bounds);
          },
          child: Text(
            isMajorRankUp ? '🎉 PROMOTED! 🎉' : 'RANK UP!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isMajorRankUp ? 28 : 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        if (isMajorRankUp) ...[
          const SizedBox(height: 8),
          Text(
            'New Tier Unlocked!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.amber.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRankTransition(RankTier previousRank, RankTier newRank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous rank (smaller, faded)
        Opacity(
              opacity: 0.5,
              child: Transform.scale(
                scale: 0.7,
                child: _buildRankBadge(previousRank, isOld: true),
              ),
            )
            .animate(delay: 200.ms)
            .fade(duration: 400.ms)
            .slideX(begin: 0.5, end: 0),

        const SizedBox(width: 20),

        // Arrow
        Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 32,
            )
            .animate(delay: 400.ms)
            .fade(duration: 300.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        const SizedBox(width: 20),

        // New rank (larger, glowing)
        if (_showNewRank)
          AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            newRank.glowColor,
                          ).withOpacity(0.3 + (_glowController.value * 0.4)),
                          blurRadius: 30 + (_glowController.value * 20),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: _buildRankBadge(newRank, isNew: true),
              )
              .animate(delay: 600.ms)
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1, 1),
                duration: 800.ms,
                curve: Curves.elasticOut,
              )
              .shimmer(
                delay: 1000.ms,
                duration: 2000.ms,
                color: Colors.white.withOpacity(0.3),
              ),
      ],
    );
  }

  Widget _buildRankBadge(
    RankTier rank, {
    bool isOld = false,
    bool isNew = false,
  }) {
    final size = isNew ? 140.0 : (isOld ? 80.0 : 100.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(rank.color).withOpacity(0.9),
            Color(rank.color).withOpacity(0.6),
            Color(rank.glowColor).withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(isNew ? 0.8 : 0.3),
          width: isNew ? 3 : 2,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: Color(rank.glowColor).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Shine effect for new rank
          if (isNew)
            AnimatedBuilder(
              animation: _shineController,
              builder: (context, child) {
                return ClipOval(
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _ShinePainter(_shineController.value),
                  ),
                );
              },
            ),

          // Rank icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rank.iconPath,
                  style: TextStyle(fontSize: isNew ? 50 : 30),
                ),
                if (isNew) ...[
                  const SizedBox(height: 4),
                  Text(
                    rank.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final newRank = widget.rankUpResult.newRank;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                '+${widget.rankUpResult.xpGained} XP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total XP: ${widget.rankUpResult.totalXP}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(newRank.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(newRank.color).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(newRank.iconPath, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Now ${newRank.tier}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(newRank.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          RankService().clearRankUpPending();
          widget.onComplete?.call();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(widget.rankUpResult.newRank.color),
                Color(widget.rankUpResult.newRank.glowColor),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(
                  widget.rankUpResult.newRank.glowColor,
                ).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'CONTINUE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 6;
    final startX = random.nextDouble() * MediaQuery.of(context).size.width;
    final duration = 3000 + random.nextInt(3000);

    return Positioned(
      left: startX,
      bottom: 0,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(
                    widget.rankUpResult.newRank.glowColor,
                  ).withOpacity(0.3 + random.nextDouble() * 0.4),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: 0,
                end: -MediaQuery.of(context).size.height,
                duration: duration.ms,
                curve: Curves.linear,
              )
              .fadeOut(delay: (duration * 0.7).ms),
    );
  }
}

/// Custom painter for shine effect
class _ShinePainter extends CustomPainter {
  final double progress;

  _ShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: [
          (progress - 0.3).clamp(0.0, 1.0),
          progress,
          (progress + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
