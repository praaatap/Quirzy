import 'package:flutter/material.dart';
import 'mascot_enums.dart';

/// Mascot character details
class MascotInfo {
  final MascotCharacter character;
  final String name;
  final String description;
  final String personality;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData fallbackIcon;

  const MascotInfo({
    required this.character,
    required this.name,
    required this.description,
    required this.personality,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.fallbackIcon,
  });

  static const Map<MascotCharacter, MascotInfo> all = {
    MascotCharacter.quizzy: MascotInfo(
      character: MascotCharacter.quizzy,
      name: 'Quizzy',
      description: 'The Wise Owl',
      personality: 'Scholarly, patient, and full of knowledge',
      primaryColor: Color(0xFF5B13EC),
      secondaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFFFFD700),
      fallbackIcon: Icons.auto_awesome,
    ),
  };

  static MascotInfo get(MascotCharacter character) => all[character]!;
}
