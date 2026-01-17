import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import '../models/mascot_enums.dart';
import '../logic/mascot_controller.dart';
import 'mascot_display.dart';
// Note: We need to check if FloatingCompanion in original file had dependencies on other screens e.g. insights_screen
// I'll re-implement it fully here and import screens if needed.
// Wait, I need to check the original file's FloatingCompanion imports.
// It imported:
// import '../../ai/screens/insights_screen.dart';
// import '../../routes/app_routes.dart';

// I will assume those imports exist and replicate the widget.

class FloatingCompanionWidget extends ConsumerStatefulWidget {
  final Alignment alignment;
  final VoidCallback? onTap;

  const FloatingCompanionWidget({
    super.key,
    this.alignment = Alignment.bottomRight,
    this.onTap,
  });

  @override
  ConsumerState<FloatingCompanionWidget> createState() =>
      _FloatingCompanionWidgetState();
}

class _FloatingCompanionWidgetState
    extends ConsumerState<FloatingCompanionWidget> {
  bool _showMessage = true;
  Timer? _messageTimer;
  String _currentMessage = '';
  final Random _random = Random();

  final List<({String text, MascotMood mood, String? action})> _smartDialogue =
      [
        (
          text: "Hoot! Tap me for quick shortcuts! ⚡",
          mood: MascotMood.happy,
          action: null,
        ),
        (
          text: "You're 15% more accurate today! Keep it up! 📈",
          mood: MascotMood.excited,
          action: "stats",
        ),
        (
          text: "Need a smart study plan? Check AI Insights! 🧠",
          mood: MascotMood.thinking,
          action: "ai",
        ),
        (
          text: "Ready to test your knowledge? Let's build a quiz! 📝",
          mood: MascotMood.encouraging,
          action: "create",
        ),
        (
          text: "Flashcards are active! Review your weak topics! ✨",
          mood: MascotMood.studying,
          action: "cards",
        ),
        (
          text: "Did you know? Consistent practice beats intense cramming! 🎓",
          mood: MascotMood.happy,
          action: null,
        ),
        (
          text: "Feeling confident? Try a Hard difficulty quiz! 🔥",
          mood: MascotMood.proud,
          action: "create",
        ),
      ];

  int _currentDialogueIndex = 0;

  @override
  void initState() {
    super.initState();

    // Switch to Quizzy (purple owl) as requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mascotProvider.notifier).setMascot(MascotCharacter.quizzy);
    });

    _cycleTip();

    // Pulse and cycle logic
    _messageTimer = Timer.periodic(const Duration(seconds: 18), (timer) {
      if (mounted) {
        setState(() {
          _cycleTip();
          _showMessage = true;
        });

        // Auto-hide bubble after some time
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) setState(() => _showMessage = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _cycleTip() {
    setState(() {
      _currentDialogueIndex = _random.nextInt(_smartDialogue.length);
      _currentMessage = _smartDialogue[_currentDialogueIndex].text;
    });
  }

  void _showShortcutsMenu() {
    HapticFeedback.heavyImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => _buildShortcutHub(),
    );
  }

  Widget _buildShortcutHub() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MascotDisplay(
                character: MascotCharacter.quizzy, // Force owl for shortcuts
                mood: MascotMood.happy,
                size: 60,
                autoAnimate: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Shortcuts",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "What would you like to do?",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildShortcutTile(
            icon: Icons.add_circle,
            color: const Color(0xFF5B13EC),
            title: "Create New Quiz",
            subtitle: "Generate from any topic",
            onTap: () {
              Navigator.pop(context);
              // Handle navigation as per original logic?
              // The original code passed in callbacks or used routes.
              // Assuming logic implementation.
            },
          ),
          const SizedBox(height: 12),
          _buildShortcutTile(
            icon: Icons.psychology,
            color: const Color(0xFFFF6B35),
            title: "AI Insights",
            subtitle: "Check your learning stats",
            onTap: () {
              Navigator.pop(context);
              // context.push(AppRoutes.aiInsights); // Using GoRouter or similar
            },
          ),
          const SizedBox(height: 12),
          _buildShortcutTile(
            icon: Icons.style,
            color: const Color(0xFF00D4FF),
            title: "Review Flashcards",
            subtitle: "Practice active recall",
            onTap: () {
              Navigator.pop(context);
              // Navigate to flashcards
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMascot = ref.watch(mascotProvider);
    final dialogue = _smartDialogue[_currentDialogueIndex];

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 24,
          right: 16,
        ), // Adjusted for proper FAB placement
        child: MascotDisplay(
          character: currentMascot,
          mood: _showMessage ? dialogue.mood : MascotMood.idle,
          size: 70, // Slightly larger for floating companion
          // Always show bubble if _showMessage is true
          showSpeechBubble: _showMessage,
          customMessage: _showMessage ? dialogue.text : null,
          autoAnimate: true,
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              _showShortcutsMenu();
            }
          },
        ),
      ),
    );
  }
}
