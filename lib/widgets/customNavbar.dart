import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: isIOS ? 84 : 72,
      decoration: BoxDecoration(
        color: isIOS ? Colors.white.withOpacity(0.8) : colorScheme.surface,
        boxShadow: isIOS
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ]
            : kElevationToShadow[6],
        borderRadius: isIOS
            ? null
            : const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: isIOS ? 0 : 4),
          child: Row(
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                context,
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                label: 'History',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _buildNavItem(
                context,
                icon: MdiIcons.sword,
                activeIcon: MdiIcons.swordCross,
                label: "Versus",
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;

    final activeColor = isIOS ? colorScheme.primary : colorScheme.primary;
    final inactiveColor = isIOS ? Colors.grey.shade600 : Colors.grey.shade600;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            if (isIOS) {
              HapticFeedback.selectionClick();
            } else {
              HapticFeedback.lightImpact();
            }
          },
          splashColor: isIOS
              ? Colors.transparent
              : colorScheme.primary.withOpacity(0.1),
          highlightColor: isIOS
              ? Colors.transparent
              : colorScheme.primary.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isIOS && isActive)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: activeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive ? 'active_$icon' : icon),
                      color: isActive ? activeColor : inactiveColor,
                      size: isIOS ? 26 : 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: isIOS ? 11 : 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: isIOS ? 0.2 : 0,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
