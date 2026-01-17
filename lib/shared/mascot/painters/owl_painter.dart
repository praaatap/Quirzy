import 'package:flutter/material.dart';
import 'dart:math';
import '../models/mascot_enums.dart'; // Import enums
import 'mascot_painter_strategy.dart';

class OwlPainter extends MascotPainterStrategy {
  OwlPainter({
    required super.character,
    required super.mood,
    required super.info,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Scale factor based on standard 100x100 size logic
    final scale = min(width, height) / 100;

    // 1. Draw Body (Purple Sphere with 3D gradient)
    _drawBody(canvas, center, scale);

    // 2. Draw Belly (Lighter purple area)
    _drawBelly(canvas, center, scale);

    // 3. Draw Eyes (Large, expressive, with lashes/brows implied by specific shape if needed)
    _drawEyes(canvas, center, scale);

    // 4. Draw Beak (Orange/Gold)
    _drawBeak(canvas, center, scale);

    // 5. Draw Graduation Cap (Glassy/Transparent top, Gold tassel)
    _drawGraduationCap(canvas, center, scale);
  }

  void _drawBody(Canvas canvas, Offset center, double scale) {
    final bodyRadius = 40 * scale;
    final paint = Paint();

    // 3D Gradient for Body (Light purple top-left to Dark purple bottom-right)
    final gradient = RadialGradient(
      center: Alignment(-0.3, -0.4),
      radius: 1.2,
      colors: [
        Color(0xFF9D65FB), // Lighter highlight
        Color(0xFF7C3AED), // Main purple
        Color(0xFF5B21B6), // Shadow
      ],
      stops: [0.0, 0.5, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: bodyRadius),
    );

    // Draw main body shape (slightly flattened sphere)
    canvas.drawCircle(center, bodyRadius, paint);

    // Add rim light for 3D effect
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..color = Colors.white.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final rimPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: bodyRadius - 1),
        3.5,
        2.5,
      );
    canvas.drawPath(rimPath, rimPaint);
  }

  void _drawBelly(Canvas canvas, Offset center, double scale) {
    // Belly is a lighter purple/pinkish area at the bottom
    final bellyRect = Rect.fromCenter(
      center: center + Offset(0, 20 * scale),
      width: 50 * scale,
      height: 35 * scale,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC084FC), Color(0xFFA855F7)],
      ).createShader(bellyRect);

    canvas.drawOval(bellyRect, paint);
  }

  void _drawEyes(Canvas canvas, Offset center, double scale) {
    final eyeY = center.dy - 5 * scale;
    final eyeXOffset = 22 * scale;
    final eyeRadius = 22 * scale; // Big eyes

    // Eye Background (Pinkish/Purple eye socket area)
    final leftEyeBg = Offset(center.dx - eyeXOffset, eyeY);
    final rightEyeBg = Offset(center.dx + eyeXOffset, eyeY);

    final bgPaint = Paint()
      ..color =
          Color(0xFFE879F9) // Pinkish purple ring around eyes
      ..style = PaintingStyle.fill;

    // Draw connected eye background (mask-like)
    canvas.drawCircle(leftEyeBg, eyeRadius + 4 * scale, bgPaint);
    canvas.drawCircle(rightEyeBg, eyeRadius + 4 * scale, bgPaint);

    // Draw actual white eyeballs
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(leftEyeBg, eyeRadius, eyePaint);
    canvas.drawCircle(rightEyeBg, eyeRadius, eyePaint);

    // Draw Pupils (Black with shine)
    _drawPupil(canvas, leftEyeBg, scale, isLeft: true);
    _drawPupil(canvas, rightEyeBg, scale, isLeft: false);
  }

  void _drawPupil(
    Canvas canvas,
    Offset center,
    double scale, {
    required bool isLeft,
  }) {
    double dx = 0;
    double dy = 0;

    // Movement based on mood
    if (mood == MascotMood.thinking) {
      dx = (isLeft ? -3 : 3) * scale;
      dy = -3 * scale;
    } else if (mood == MascotMood.sad) {
      dy = 5 * scale;
    }

    final pupilCenter = center + Offset(dx, dy);
    final pupilRadius = 12 * scale;

    // Main black pupil
    canvas.drawCircle(pupilCenter, pupilRadius, Paint()..color = Colors.black);

    // Big white reflection (Top Left)
    canvas.drawOval(
      Rect.fromCenter(
        center: pupilCenter + Offset(-4 * scale, -4 * scale),
        width: 8 * scale,
        height: 6 * scale,
      ),
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Small secondary reflection (Bottom Right)
    canvas.drawCircle(
      pupilCenter + Offset(4 * scale, 4 * scale),
      2 * scale,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  void _drawBeak(Canvas canvas, Offset center, double scale) {
    final beakCenter = center + Offset(0, 10 * scale);

    final path = Path();
    path.moveTo(beakCenter.dx - 6 * scale, beakCenter.dy);
    path.quadraticBezierTo(
      beakCenter.dx,
      beakCenter.dy + 8 * scale,
      beakCenter.dx + 6 * scale,
      beakCenter.dy,
    );
    path.quadraticBezierTo(
      beakCenter.dx,
      beakCenter.dy + 15 * scale,
      beakCenter.dx - 6 * scale,
      beakCenter.dy,
    );
    path.close();

    final paint = Paint()
      ..color =
          Color(0xFFFFB300) // Golden/Orange
      ..style = PaintingStyle.fill;

    // Draw shadow manually
    final shadowPath = Path();
    shadowPath.addPath(path, Offset(0, 2 * scale));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black26
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * scale),
    );

    canvas.drawPath(path, paint);
  }

  void _drawGraduationCap(Canvas canvas, Offset center, double scale) {
    final capCenter = center + Offset(0, -35 * scale);

    // 1. Cap Board (Diamond shape) - Glassy look
    final path = Path();
    final width = 60 * scale;
    final height = 15 * scale; // Perspective flatten

    path.moveTo(capCenter.dx, capCenter.dy - height); // Top
    path.lineTo(capCenter.dx + width, capCenter.dy); // Right
    path.lineTo(capCenter.dx, capCenter.dy + height); // Bottom
    path.lineTo(capCenter.dx - width, capCenter.dy); // Left
    path.close();

    // Glassy Material
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    canvas.drawPath(path, glassPaint);
    canvas.drawPath(path, borderPaint);

    // 2. Cap Skullcap (Underneath)
    final skullCapRect = Rect.fromCenter(
      center: capCenter + Offset(0, 10 * scale),
      width: 50 * scale,
      height: 30 * scale,
    );
    canvas.drawArc(
      skullCapRect,
      pi,
      pi,
      false,
      Paint()..color = info.primaryColor,
    );

    // 3. Tassel (Gold)
    final tasselStart = capCenter; // Center of cap
    final tasselEnd = capCenter + Offset(width * 0.8, height * 2);

    final tasselPaint = Paint()
      ..color = Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    final tasselPath = Path();
    tasselPath.moveTo(tasselStart.dx, tasselStart.dy);
    tasselPath.quadraticBezierTo(
      tasselStart.dx + width * 0.5,
      tasselStart.dy,
      tasselEnd.dx,
      tasselEnd.dy,
    );

    canvas.drawPath(tasselPath, tasselPaint);

    // Tassel Fringe
    final fringeCenter = tasselEnd;
    final fringePaint = Paint()..color = Color(0xFFFFD700);
    canvas.drawCircle(fringeCenter, 4 * scale, fringePaint);
  }
}
