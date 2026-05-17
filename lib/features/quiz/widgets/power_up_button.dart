import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PowerUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isUsed;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const PowerUpButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isUsed,
    required this.onTap,
    this.isActive = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUsed
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap();
            },
      child: Opacity(
        opacity: isUsed ? 0.4 : 1.0,
        child: Column(
          children: [
            Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.2)
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? color : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    icon,
                    color: isUsed ? Colors.grey : color,
                    size: 26,
                  ),
                )
                .animate(target: isActive ? 1 : 0)
                .scale(end: const Offset(1.05, 1.05), duration: 200.ms)
                .then()
                .shimmer(
                  duration: 1.seconds,
                  delay: 2.seconds,
                ), // Shimmer if active

            const SizedBox(height: 8),

            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUsed
                    ? Colors.grey
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
