import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptic Feedback
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/quiz/screens/quiz_question_screen.dart';

class StartQuizScreen extends StatefulWidget {
  final String quizTitle;
  final String quizId;
  final List<Map<String, dynamic>> questions;
  final String? difficulty;

  const StartQuizScreen({
    super.key,
    required this.quizTitle,
    required this.questions,
    required this.quizId,
    this.difficulty,
  });

  @override
  State<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen>
    with SingleTickerProviderStateMixin {
  // Use ValueNotifiers for high-performance updates without setState
  late final ValueNotifier<int> _questionCountNotifier;
  late final ValueNotifier<int> _timeNotifier;
  late final ValueNotifier<String> _difficultyNotifier;
  late final ValueNotifier<bool> _shuffleNotifier;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Logic to determine initial question count
    final availableQuestions = widget.questions.length;
    int initialCount = 10;
    if (availableQuestions < 10) {
      initialCount = availableQuestions;
    }

    // Initialize Notifiers
    _questionCountNotifier = ValueNotifier(initialCount);
    _timeNotifier = ValueNotifier(30);
    _difficultyNotifier = ValueNotifier(widget.difficulty ?? 'medium');
    _shuffleNotifier = ValueNotifier(false); // New Feature: Shuffle

    // Animation Setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _questionCountNotifier.dispose();
    _timeNotifier.dispose();
    _difficultyNotifier.dispose();
    _shuffleNotifier.dispose();
    super.dispose();
  }

  void _startQuiz() {
    // Collect values from notifiers
    final count = _questionCountNotifier.value;
    final time = _timeNotifier.value;
    final diff = _difficultyNotifier.value;
    final shuffle = _shuffleNotifier.value;

    List<Map<String, dynamic>> quizQuestions = List.from(widget.questions);

    // Feature: Shuffle
    if (shuffle) {
      quizQuestions.shuffle();
    }

    // Trim list
    final finalQuestions = count < quizQuestions.length
        ? quizQuestions.sublist(0, count)
        : quizQuestions;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizQuestionScreen(
          quizId: widget.quizId,
          quizTitle: widget.quizTitle,
          questions: finalQuestions,
          difficulty: diff,
          timePerQuestion: time,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableQuestions = widget.questions.length;
    final maxQuestions = availableQuestions < 50 ? availableQuestions : 50;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back,
                color: theme.colorScheme.onSurface, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Static Background (Won't rebuild)
          const _BackgroundDecoration(),

          // 2. Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                children: [
                  _HeaderSection(
                    title: widget.quizTitle,
                    availableCount: availableQuestions,
                  ),
                  const SizedBox(height: 32),

                  // Difficulty Selector (Uses ValueListenableBuilder)
                  Text(
                    "Select Difficulty",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: _difficultyNotifier,
                    builder: (context, currentDifficulty, _) {
                      return Row(
                        children: [
                          Expanded(
                              child: _DifficultyCard(
                            value: 'easy',
                            label: 'Easy',
                            color: Colors.green,
                            isSelected: currentDifficulty == 'easy',
                            onTap: (val) {
                              HapticFeedback.lightImpact();
                              _difficultyNotifier.value = val;
                            },
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _DifficultyCard(
                            value: 'medium',
                            label: 'Medium',
                            color: Colors.orange,
                            isSelected: currentDifficulty == 'medium',
                            onTap: (val) {
                              HapticFeedback.lightImpact();
                              _difficultyNotifier.value = val;
                            },
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _DifficultyCard(
                            value: 'hard',
                            label: 'Hard',
                            color: Colors.redAccent,
                            isSelected: currentDifficulty == 'hard',
                            onTap: (val) {
                              HapticFeedback.lightImpact();
                              _difficultyNotifier.value = val;
                            },
                          )),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  Text(
                    "Configuration",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question Slider (Performance Optimized)
                  _PerformanceSliderCard(
                    title: "Questions",
                    icon: Icons.copy_all_rounded,
                    notifier: _questionCountNotifier,
                    min: availableQuestions >= 5 ? 5.0 : availableQuestions.toDouble(),
                    max: maxQuestions.toDouble(),
                    divisions: maxQuestions >= 5 ? ((maxQuestions - 5) ~/ 5).clamp(1, 10) : 1,
                    unit: "",
                    step: 5, // Custom logic handled inside
                    isQuestionCount: true,
                  ),

                  const SizedBox(height: 16),

                  // Timer Slider (Performance Optimized)
                  _PerformanceSliderCard(
                    title: "Time per Question",
                    icon: Icons.timer_outlined,
                    notifier: _timeNotifier,
                    min: 10,
                    max: 60,
                    divisions: 10,
                    unit: "s",
                    step: 1,
                  ),

                  const SizedBox(height: 16),

                  // Shuffle Toggle (New Feature)
                  _ShuffleToggleCard(notifier: _shuffleNotifier),
                ],
              ),
            ),
          ),

          // 3. Bottom Floating Bar (Rebuilds only necessary parts)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              theme: theme,
              diffNotifier: _difficultyNotifier,
              timeNotifier: _timeNotifier,
              countNotifier: _questionCountNotifier,
              onStart: _startQuiz,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. STATIC BACKGROUND (Const Widget)
// ==========================================
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    // Only access theme for colors inside build
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ),
        // Add a second blob for better visuals
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. HEADER SECTION (Const Capable)
// ==========================================
class _HeaderSection extends StatelessWidget {
  final String title;
  final int availableCount;

  const _HeaderSection({required this.title, required this.availableCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'quiz_icon_$title',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest, // Modern Token
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total Available: $availableCount Qs',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. DIFFICULTY CARD (Stateless)
// ==========================================
class _DifficultyCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isSelected;
  final Function(String) onTap;

  const _DifficultyCard({
    required this.value,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.dividerColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. PERFORMANCE SLIDER (Isolates Rebuilds)
// ==========================================
class _PerformanceSliderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ValueNotifier<int> notifier;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final int step;
  final bool isQuestionCount;

  const _PerformanceSliderCard({
    required this.title,
    required this.icon,
    required this.notifier,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.step,
    this.isQuestionCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This card rebuilds ONCE. The slider inside rebuilds via ValueListenableBuilder.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Optimized: Only the text number rebuilds
              ValueListenableBuilder<int>(
                valueListenable: notifier,
                builder: (context, value, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$value$unit",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Optimized: Only the slider rebuilds
          ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (context, value, _) {
              return SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withOpacity(0.1),
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: (newValue) {
                    HapticFeedback.selectionClick(); // Performance feel
                    int intVal;
                    if (isQuestionCount && min >= 5) {
                         // Logic for 5-step increments
                         intVal = (newValue ~/ 5) * 5;
                         if (intVal < 5) intVal = 5;
                    } else {
                        intVal = newValue.round();
                    }
                    notifier.value = intVal;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. NEW FEATURE: SHUFFLE TOGGLE
// ==========================================
class _ShuffleToggleCard extends StatelessWidget {
  final ValueNotifier<bool> notifier;

  const _ShuffleToggleCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shuffle_rounded,
                  color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                "Shuffle Questions",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, value, _) {
              return Switch(
                value: value,
                activeColor: theme.colorScheme.secondary,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  notifier.value = val;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. BOTTOM ACTION BAR
// ==========================================
class _BottomActionBar extends StatelessWidget {
  final ThemeData theme;
  final ValueNotifier<String> diffNotifier;
  final ValueNotifier<int> timeNotifier;
  final ValueNotifier<int> countNotifier;
  final VoidCallback onStart;

  const _BottomActionBar({
    required this.theme,
    required this.diffNotifier,
    required this.timeNotifier,
    required this.countNotifier,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor.withOpacity(0.0),
            theme.scaffoldBackgroundColor.withOpacity(0.95),
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dynamic Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: diffNotifier,
                builder: (context, val, _) => _buildQuickStat(
                    theme, "Difficulty", val.toUpperCase()),
              ),
              Container(height: 20, width: 1, color: theme.dividerColor),
              // Listens to BOTH time and count to calc duration
              AnimatedBuilder(
                animation: Listenable.merge([timeNotifier, countNotifier]),
                builder: (context, _) {
                   final totalSec = timeNotifier.value * countNotifier.value;
                   return _buildQuickStat(
                    theme, "Duration", _formatDuration(totalSec));
                },
              ),
              Container(height: 20, width: 1, color: theme.dividerColor),
              ValueListenableBuilder<int>(
                valueListenable: countNotifier,
                builder: (context, val, _) => _buildQuickStat(
                    theme, "Points", "${val * 10}"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Start Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Start Quiz",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes} min';
    }
    return '${seconds} sec';
  }
}