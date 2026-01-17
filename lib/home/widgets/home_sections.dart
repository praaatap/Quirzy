import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../subscription/screens/subscription_screen.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final String greeting;
  final Color textMain;
  final Color textSub;
  final Color primaryColor;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.photoUrl,
    required this.greeting,
    required this.textMain,
    required this.textSub,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, const Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          photoUrl!,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'Q',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'Q',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    userName.isNotEmpty ? userName : 'Friend',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Pro Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFFD700)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeroSection extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color textMain;
  final Color textSub;
  final Color primaryColor;
  final String greeting;

  const HomeHeroSection({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.textMain,
    required this.textSub,
    required this.primaryColor,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: isDark
                      ? Border.all(color: const Color(0xFF2D2540))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      greeting,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMain,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 600.ms, delay: 100.ms)
              .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 20),
          RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: localizations.homeTitle1),
                    TextSpan(
                      text: localizations.homeTitle2,
                      style: TextStyle(
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color textSub;
  final Function(String) onAction;

  const QuickActions({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.textSub,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final quickActions = [
      {
        'icon': Icons.auto_awesome_rounded,
        'label': localizations.actionAIGen,
        'key': 'AI Gen',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.bolt_rounded,
        'label': localizations.actionQuick,
        'key': 'Quick',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.school_rounded,
        'label': localizations.actionStudy,
        'key': 'Study',
        'color': const Color(0xFF10B981),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: quickActions.asMap().entries.map((entry) {
          final delay = entry.key * 100;
          final label = entry.value['label'] as String;
          final key = entry.value['key'] as String;

          return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onAction(key);
                },
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(color: const Color(0xFF2D2540))
                            : null,
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Icon(
                        entry.value['icon'] as IconData,
                        color: entry.value['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSub,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (300 + delay).ms)
              .fade(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
        }).toList(),
      ),
    );
  }
}

class TopicInputSection extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final Color textMain;
  final Color textSub;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onMicTap;
  final Color primaryColor;

  const TopicInputSection({
    super.key,
    required this.isDark,
    required this.surfaceColor,
    required this.textMain,
    required this.textSub,
    required this.controller,
    required this.focusNode,
    required this.onMicTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                localizations.createFromTopic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            minLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: textMain,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? surfaceColor : Colors.white,
              hintText: localizations.enterTopicHint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: isDark ? Colors.white60 : textSub.withOpacity(0.6),
              ),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onMicTap();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GenerateQuizButton extends StatelessWidget {
  final bool isGenerating;
  final VoidCallback onTap;
  final Color primaryColor;

  const GenerateQuizButton({
    super.key,
    required this.isGenerating,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child:
          GestureDetector(
                onTap: isGenerating ? null : onTap,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isGenerating)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      else ...[
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          localizations.generateQuizButton,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.02,
                duration: 1000.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(delay: 500.ms, duration: 2000.ms, color: Colors.white12),
    );
  }
}
