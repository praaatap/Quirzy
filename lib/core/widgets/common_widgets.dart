// Common reusable widgets
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/config.dart';

/// Primary Button Widget
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConfig.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Stat Card Widget
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ?? ThemeConfig.primaryColor;

    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: ThemeConfig.spacingMedium),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: ThemeConfig.fontSizeXXL,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
            ),
          ),
          const SizedBox(height: ThemeConfig.spacingXS),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: ThemeConfig.fontSizeSmall,
              color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Card Widget
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.surfaceDark : ThemeConfig.surfaceLight,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
              ),
              child: Icon(icon, color: ThemeConfig.primaryColor),
            ),
            const SizedBox(width: ThemeConfig.spacingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: isDark ? ThemeConfig.textPrimaryDark : ThemeConfig.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXS),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: ThemeConfig.fontSizeMedium,
                      color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? ThemeConfig.textSecondaryDark : ThemeConfig.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }
}
