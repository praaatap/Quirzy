import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mascot_enums.dart';
import '../models/mascot_info.dart';
import '../logic/mascot_controller.dart';
import 'mascot_display.dart';

class MascotSelector extends ConsumerWidget {
  const MascotSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mascotProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose Your Study Buddy',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a companion to help you learn!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),

        // Mascot grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: MascotCharacter.values.length,
          itemBuilder: (context, index) {
            final character = MascotCharacter.values[index];
            final info = MascotInfo.get(character);
            final isSelected = character == selected;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(mascotProvider.notifier).setMascot(character);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? (isSelected
                            ? info.primaryColor.withOpacity(0.2)
                            : const Color(0xFF1A1A1A))
                      : (isSelected
                            ? info.primaryColor.withOpacity(0.1)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? info.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: info.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        MascotDisplay(
                          character: character,
                          mood: isSelected ? MascotMood.happy : MascotMood.idle,
                          size: 80,
                          autoAnimate: isSelected,
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: info.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? info.primaryColor
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
