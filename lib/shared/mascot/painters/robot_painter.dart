import 'package:flutter/material.dart';
import '../models/mascot_enums.dart'; // Import enums
import 'mascot_painter_strategy.dart';

class RobotPainter extends MascotPainterStrategy {
  RobotPainter({
    required super.character,
    required super.mood,
    required super.info,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
}
