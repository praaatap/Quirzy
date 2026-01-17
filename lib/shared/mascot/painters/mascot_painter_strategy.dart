import 'package:flutter/material.dart';
import '../models/mascot_enums.dart';
import '../models/mascot_info.dart';

/// Abstract base class for all mascot painters.
/// Adheres to the Strategy Pattern, allowing easy addition of new mascots.
abstract class MascotPainterStrategy extends CustomPainter {
  final MascotCharacter character;
  final MascotMood mood;
  final MascotInfo info;

  MascotPainterStrategy({
    required this.character,
    required this.mood,
    required this.info,
  });

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(covariant MascotPainterStrategy oldDelegate) {
    return oldDelegate.character != character || oldDelegate.mood != mood;
  }
}
