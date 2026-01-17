import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Duolingo-style mascot celebration overlay
/// Shows Quizzy celebrating with confetti when user completes quiz/flashcards

class MascotCelebration extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String? customMessage;
  final VoidCallback? onDismiss;
  final bool autoHide;
  final Duration autoHideDuration;

  const MascotCelebration({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.customMessage,
    this.onDismiss,
    this.autoHide = true,
    this.autoHideDuration = const Duration(seconds: 4),
  });

  /// Show celebration as overlay
  static Future<void> show(
    BuildContext context, {
    required int score,
    required int totalQuestions,
    String? customMessage,
  }) async {
    HapticFeedback.heavyImpact();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebration',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MascotCelebration(
          score: score,
          totalQuestions: totalQuestions,
          customMessage: customMessage,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MascotCelebration> createState() => _MascotCelebrationState();
}

class _MascotCelebrationState extends State<MascotCelebration>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  static const primaryColor = Color(0xFF5B13EC);
  static const secondaryColor = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    // Bounce animation (used for controller disposal)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceController.forward();

    // Float animation (continuous)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Auto hide
    if (widget.autoHide) {
      Future.delayed(widget.autoHideDuration, () {
        if (mounted) widget.onDismiss?.call();
      });
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  double get percentage => widget.totalQuestions > 0
      ? (widget.score / widget.totalQuestions) * 100
      : 0;

  String get celebrationMessage {
    if (widget.customMessage != null) return widget.customMessage!;

    if (percentage >= 100) return "PERFECT SCORE! 🏆";
    if (percentage >= 90) return "Outstanding! 🌟";
    if (percentage >= 80) return "Excellent work! ⭐";
    if (percentage >= 70) return "Great job! 💪";
    if (percentage >= 60) return "Good effort! 👍";
    if (percentage >= 50) return "Keep learning! 📚";
    return "Don't give up! 💪";
  }

  String get mascotMessage {
    if (percentage >= 90) return "I'm so proud of you! You're a genius! 🦉✨";
    if (percentage >= 70) return "Hoot hoot! That was amazing! Keep it up! 🦉";
    if (percentage >= 50) return "Good work! Practice makes perfect! 🦉📚";
    return "Every question is a chance to learn! Let's try again! 🦉💪";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap to dismiss
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.transparent),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF5B13EC),
                Color(0xFF8B5CF6),
                Color(0xFFFFD700),
                Color(0xFF10B981),
                Color(0xFFEC4899),
                Color(0xFF3B82F6),
              ],
              numberOfParticles: 30,
              gravity: 0.2,
              emissionFrequency: 0.05,
            ),
          ),

          // Main celebration content
          Center(
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mascot
                  _buildMascot().animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 24),

                  // Speech bubble with message
                  _buildSpeechBubble()
                      .animate(delay: 300.ms)
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 32),

                  // Score display
                  _buildScoreDisplay()
                      .animate(delay: 500.ms)
                      .fade(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 24),

                  // Continue button
                  _buildContinueButton()
                      .animate(delay: 700.ms)
                      .fade(duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascot() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Owl face
          CustomPaint(
            size: const Size(100, 100),
            painter: _QuizzyPainter(
              isHappy: percentage >= 50,
              isCelebrating: percentage >= 70,
            ),
          ),
          // Stars around (for high scores)
          if (percentage >= 80) ...[
            Positioned(
              top: 5,
              right: 10,
              child: Icon(Icons.star, color: Colors.amber, size: 20)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                  ),
            ),
            Positioned(
              top: 15,
              left: 5,
              child: Icon(Icons.star, color: Colors.amber, size: 16)
                  .animate(delay: 200.ms, onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            celebrationMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mascotMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildScoreBadge(
          icon: Icons.check_circle_rounded,
          value: '${widget.score}',
          label: 'Correct',
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        _buildScoreBadge(
          icon: Icons.percent_rounded,
          value: '${percentage.round()}%',
          label: 'Score',
          color: primaryColor,
        ),
        const SizedBox(width: 16),
        _buildScoreBadge(
          icon: Icons.quiz_rounded,
          value: '${widget.totalQuestions}',
          label: 'Total',
          color: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildScoreBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onDismiss?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Quizzy owl face
class _QuizzyPainter extends CustomPainter {
  final bool isHappy;
  final bool isCelebrating;

  _QuizzyPainter({this.isHappy = true, this.isCelebrating = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1E293B);

    // Left eye
    canvas.drawCircle(Offset(center.dx - 18, center.dy - 10), 16, eyePaint);
    canvas.drawCircle(Offset(center.dx - 18, center.dy - 8), 8, pupilPaint);

    // Right eye
    canvas.drawCircle(Offset(center.dx + 18, center.dy - 10), 16, eyePaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy - 8), 8, pupilPaint);

    // Eye sparkles
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 14, center.dy - 12), 3, sparklePaint);
    canvas.drawCircle(Offset(center.dx + 22, center.dy - 12), 3, sparklePaint);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFFB347);
    final beakPath = Path();
    beakPath.moveTo(center.dx, center.dy + 8);
    beakPath.lineTo(center.dx - 8, center.dy + 20);
    beakPath.lineTo(center.dx + 8, center.dy + 20);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Cheeks (if happy)
    if (isHappy) {
      final cheekPaint = Paint()
        ..color = const Color(0xFFFFB6C1).withOpacity(0.6);
      canvas.drawCircle(Offset(center.dx - 30, center.dy + 5), 8, cheekPaint);
      canvas.drawCircle(Offset(center.dx + 30, center.dy + 5), 8, cheekPaint);
    }

    // Eyebrows for celebrating
    if (isCelebrating) {
      final browPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Raised happy eyebrows
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx - 18, center.dy - 30),
          width: 20,
          height: 10,
        ),
        3.14,
        3.14,
        false,
        browPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + 18, center.dy - 30),
          width: 20,
          height: 10,
        ),
        3.14,
        3.14,
        false,
        browPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
