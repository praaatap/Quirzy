import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/core/widgets/micro_animations.dart';
import 'package:quirzy/core/widgets/quiz_timer_widget.dart';
import 'package:quirzy/core/widgets/level_up_animation.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

/// 🎨 MICRO-ANIMATIONS DEMO SCREEN
/// Test all animations in one place
class AnimationsDemoScreen extends StatefulWidget {
  const AnimationsDemoScreen({super.key});

  @override
  State<AnimationsDemoScreen> createState() => _AnimationsDemoScreenState();
}

class _AnimationsDemoScreenState extends State<AnimationsDemoScreen> {
  final GlobalKey<AnimatedTapButtonState> _buttonKey = GlobalKey();
  final CountDownController _timerController = CountDownController();
  int _currentXP = 75;
  int _currentLevel = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Micro-Animations Demo',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // SECTION 1: TIMER ANIMATIONS
            // ==========================================
            _buildSection(
              '⏱️ Timer Animations',
              'Countdown with color changes: Green → Yellow → Red',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Circular Countdown Timer
                QuizCountdownTimer(
                  duration: 30,
                  controller: _timerController,
                  isActive: false,
                ),
                // Custom Animated Timer
                AnimatedCircularTimer(seconds: 20, isPaused: false),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: CompactTimerIndicator(
                secondsRemaining: 8,
                totalSeconds: 30,
              ),
            ),

            const SizedBox(height: 40),

            // ==========================================
            // SECTION 2: BUTTON ANIMATIONS
            // ==========================================
            _buildSection(
              '🎯 Button Animations',
              'Tap to shrink, trigger success bounce',
            ),
            const SizedBox(height: 16),
            AnimatedTapButton(
              key: _buttonKey,
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tapped!')));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Tap Me!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _buttonKey.currentState?.triggerSuccessBounce();
                HapticFeedback.heavyImpact();
              },
              child: const Text('Trigger Success Bounce'),
            ),

            const SizedBox(height: 40),

            // ==========================================
            // SECTION 3: XP ANIMATIONS
            // ==========================================
            _buildSection(
              '✨ XP Animations',
              'Number count-up and progress bars',
            ),
            const SizedBox(height: 16),

            // XP Counter
            Center(
              child: AnimatedXPCounter(
                startValue: 100,
                endValue: 175,
                duration: const Duration(seconds: 2),
              ),
            ),

            const SizedBox(height: 24),

            // Linear XP Bar
            AnimatedXPBar(
              percent: _currentXP / 100,
              height: 12,
              showPercentText: false,
            ),

            const SizedBox(height: 8),
            Text(
              '$_currentXP / 100 XP',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Circular XP Progress
            Center(
              child: AnimatedCircularXP(
                percent: _currentXP / 100,
                radius: 60,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                    Text(
                      '$_currentLevel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentXP = (_currentXP + 10).clamp(0, 100);
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('+10 XP'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentXP = (_currentXP - 10).clamp(0, 100);
                    });
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('-10 XP'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ==========================================
            // SECTION 4: LEVEL UP ANIMATION
            // ==========================================
            _buildSection(
              '🎉 Level Up Animation',
              'Confetti, badge, and haptic feedback',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => LevelUpAnimation(
                    newLevel: _currentLevel + 1,
                    xpEarned: 150,
                    onComplete: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentLevel++;
                        _currentXP = 0;
                      });
                    },
                  ),
                );
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text(
                'Show Level Up Animation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                _showXPPopup(25, 'Correct Answer!');
              },
              icon: const Icon(Icons.stars),
              label: const Text('Show XP Gain Popup'),
            ),

            const SizedBox(height: 40),

            // ==========================================
            // SECTION 5: VISUAL EFFECTS
            // ==========================================
            _buildSection('💫 Visual Effects', 'Glow, ripple, and shimmer'),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Pulsing Glow
                Column(
                  children: [
                    PulsingGlow(
                      glowColor: Colors.purple,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pulsing Glow',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ],
                ),

                // Shimmer Effect
                Column(
                  children: [
                    ShimmerEffect(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.flash_on, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shimmer',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Level Up Badge
            Center(child: LevelUpBadge(level: 5)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showXPPopup(int amount, String reason) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 0,
        right: 0,
        child: Center(
          child: XPGainPopup(xpAmount: amount, reason: reason),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
