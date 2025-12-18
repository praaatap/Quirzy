import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class VersusPage extends StatelessWidget {
  const VersusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final size = media.size;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // Circular back button to match app style
        title: Text(
          'Versus Mode',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep layout pleasant on large screens/tablets
            final double maxContentWidth = math.min(constraints.maxWidth, 800);

            // Responsive horizontal padding
            final double horizontalPadding = math.min(
              40.0,
              math.max(16.0, constraints.maxWidth * 0.06),
            );

            // Icon size scales with width but clamps to comfortable range
            final double iconSize = clampDouble(
              constraints.maxWidth * 0.15,
              56,
              120,
            );

            // Vertical spacing scaled relative to height
            final double verticalGap = math.max(12.0, size.height * 0.03);

            // Decide grid columns for features
            final bool useTwoColumns = constraints.maxWidth > 520;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Decorative circular background (RepaintBoundary to reduce repaints)
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: -100,
                            right: -100,
                            child: RepaintBoundary(
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(0.06),
                                ),
                              ),
                            ),
                          ),
                          // Animated icon with adaptive size
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.92 + (0.14 * value),
                                child: Container(
                                  width: iconSize + 24,
                                  height: iconSize + 24,
                                  padding:
                                      EdgeInsets.all(math.max(12, iconSize * 0.12)),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.primary.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.sports_esports_rounded,
                                    size: iconSize,
                                    color: theme.colorScheme.primary,
                                    semanticLabel: 'Versus icon',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: verticalGap),

                      // Coming soon badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'COMING SOON',
                          style: GoogleFonts.poppins(
                            fontSize: clampDouble(
                              constraints.maxWidth * 0.014,
                              11,
                              14,
                            ),
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: verticalGap * 0.7),

                      // Title
                      Text(
                        'Challenge Mode',
                        style: GoogleFonts.poppins(
                          fontSize: clampDouble(
                            constraints.maxWidth * 0.038,
                            20,
                            32,
                          ),
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: verticalGap * 0.35),

                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding * 0.2,
                        ),
                        child: Text(
                          'Challenge your friends and compete in real-time quiz battles. This exciting feature is coming in the next update!',
                          style: GoogleFonts.poppins(
                            fontSize: clampDouble(
                              constraints.maxWidth * 0.02,
                              14,
                              18,
                            ),
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: verticalGap),

                      // Features container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            isDark ? 0.05 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.12),
                          ),
                        ),
                        child: useTwoColumns
                            ? GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 4.5,
                                children: const [
                                  _FeatureItemData(
                                    icon: Icons.person_search,
                                    text: 'Search & challenge friends',
                                  ),
                                  _FeatureItemData(
                                    icon: Icons.timer_outlined,
                                    text: 'Real-time quiz battles',
                                  ),
                                  _FeatureItemData(
                                    icon: Icons.leaderboard,
                                    text: 'Track your wins & losses',
                                  ),
                                  _FeatureItemData(
                                    icon: Icons.shield,
                                    text: 'Fair-matchmaking & anti-cheat',
                                  ),
                                ],
                              )
                            : Column(
                                children: const [
                                  _FeatureItemData(
                                    icon: Icons.person_search,
                                    text: 'Search & challenge friends',
                                  ),
                                  SizedBox(height: 12),
                                  _FeatureItemData(
                                    icon: Icons.timer_outlined,
                                    text: 'Real-time quiz battles',
                                  ),
                                  SizedBox(height: 12),
                                  _FeatureItemData(
                                    icon: Icons.leaderboard,
                                    text: 'Track your wins & losses',
                                  ),
                                  SizedBox(height: 12),
                                  _FeatureItemData(
                                    icon: Icons.shield,
                                    text: 'Fair-matchmaking & anti-cheat',
                                  ),
                                ],
                              ),
                      ),

                      SizedBox(height: verticalGap),

                      // Version info
                      Text(
                        'Available in version 1.1',
                        style: GoogleFonts.poppins(
                          fontSize: clampDouble(
                            constraints.maxWidth * 0.016,
                            12,
                            14,
                          ),
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// small helper to clamp double values
double clampDouble(double value, double minVal, double maxVal) {
  return math.max(minVal, math.min(maxVal, value));
}

/// Feature item widget data wrapper (stateless and responsive)
class _FeatureItemData extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItemData({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final availableWidth = media.size.width;
    final textStyle = GoogleFonts.poppins(
      fontSize: clampDouble(availableWidth * 0.018, 13, 16),
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      container: true,
      label: text,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
