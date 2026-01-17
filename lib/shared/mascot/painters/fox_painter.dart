import 'package:flutter/material.dart';
import '../models/mascot_enums.dart'; // Import enums
import 'mascot_painter_strategy.dart';

class FoxPainter extends MascotPainterStrategy {
  FoxPainter({
    required super.character,
    required super.mood,
    required super.info,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
}
