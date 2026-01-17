import 'package:flutter/material.dart';
import '../models/mascot_enums.dart'; // Import enums
import 'mascot_painter_strategy.dart';

class CatPainter extends MascotPainterStrategy {
  CatPainter({
    required super.character,
    required super.mood,
    required super.info,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
}
