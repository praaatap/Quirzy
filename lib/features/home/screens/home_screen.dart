import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:quirzy/features/home/widgets/daily_reward_sheet.dart';
import 'package:quirzy/features/quiz/screens/quiz_generation_loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quirzy/features/quiz/screens/start_quiz_screen.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';
import 'package:quirzy/features/flashcards/screens/flashcards_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quirzy/core/services/ad_service.dart';

// ==========================================
// REDESIGNED HOME SCREEN
// Full Dark/Light Theme Support
// ==========================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isGenerating = false;
  int _remainingFree = 5;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  String _userName = 'Quiz Master';

  // Cached instances for performance
  SharedPreferences? _prefs;

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  bool get wantKeepAlive => true;

  // Static colors
  static const primaryColor = Color(0xFF5B13EC);
  static const primaryLight = Color(0xFFEFE9FD);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initAnimations();
    _speech = stt.SpeechToText();
    _initAdService();
  }

  Future<void> _initAdService() async {
    await AdService().initialize();
    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read(key: 'user_name');
    if (mounted && name != null) {
      setState(() => _userName = name);
    }
  }

  void _initAnimations() {
    // Triggers daily reward check after a slight delay for better UX
    Future.delayed(const Duration(seconds: 1), _checkDailyReward);
  }

  Future<void> _checkDailyReward() async {
    if (!mounted) return;

    // Use cached prefs for better performance
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;

    final lastDateStr = prefs.getString('last_daily_reward_date');
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (lastDateStr != todayStr) {
      final currentStreak = (prefs.getInt('daily_streak') ?? 0) + 1;

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DailyRewardSheet(
          day: currentStreak,
          xpReward: 50 + (currentStreak * 10), // Scaling reward
          onClaim: () async {
            await prefs.setString('last_daily_reward_date', todayStr);
            await prefs.setInt('daily_streak', currentStreak);
            // Here you would typically add XP to your user provider
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    // Proper cleanup to prevent memory leaks
    _topicController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // --- SPEECH RECOGNITION ---

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
              Navigator.pop(
                context,
              ); // Close dialog if listening stops naturally
            }
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);

        // Show Google-style listening DIALOG (Centered)
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E1730) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Listening...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastWords.isEmpty ? 'Say your topic' : _lastWords,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    AvatarGlow(
                      animate: true,
                      glowColor: const Color(0xFF4285F4), // Google Blue
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      startDelay: const Duration(milliseconds: 100),
                      child: GestureDetector(
                        onTap: () {
                          _speech.stop();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4285F4), // Blue
                                  Color(0xFFEA4335), // Red
                                  Color(0xFFFBBC05), // Yellow
                                  Color(0xFF34A853), // Green
                                ],
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).then((_) {
          if (_isListening) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        });

        _speech.listen(
          onResult: (val) {
            setState(() {
              _topicController.text = val.recognizedWords;
              _lastWords = val.recognizedWords;
              // Keep cursor at end
              _topicController.selection = TextSelection.fromPosition(
                TextPosition(offset: _topicController.text.length),
              );
            });
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // NOTE: Removed _showListeningSheet as it is replaced by dialog logic inside _listen

  // --- QUIZ GENERATION FLOW ---

  void _handleGenerate() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a topic first',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // Directly show configuration dialog (Ad check moved to confirmation)
    _showQuizConfigurationDialog(topic);
  }

  void _showQuizConfigurationDialog(String topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuizConfigSheet(
        topic: topic,
        onGenerate: (count, difficulty) {
          Navigator.pop(context); // Close sheet first

          // Trigger Ad Check Here
          if (!AdService().isLimitReached()) {
            AdService().incrementQuizCount();
            _startGeneration(topic, count, difficulty);
          } else {
            AdService().showRewardedAd(
              onRewardEarned: () {
                if (mounted) {
                  _startGeneration(topic, count, difficulty);
                }
              },
              onAdFailed: () {
                // Fallback
                if (mounted) {
                  _startGeneration(topic, count, difficulty);
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _startGeneration(
    String topic,
    int count,
    String difficulty,
  ) async {
    // Navigate to the beautiful Gemini-like loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizGenerationLoadingScreen(),
      ),
    );

    try {
      final quizService = ref.read(quizServiceProvider);
      // Pass the count and difficulty to the service
      final result = await quizService.generateQuiz(
        topic,
        questionCount: count,
        difficulty: difficulty.toLowerCase(),
      );

      if (mounted) {
        // Remove the loading screen
        Navigator.pop(context);

        _topicController.clear();
        final quizId =
            result['quizId']?.toString() ?? result['id']?.toString() ?? '';
        final quizTitle = result['title']?.toString() ?? topic;
        final questions = List<Map<String, dynamic>>.from(
          result['questions'] ?? [],
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                StartQuizScreen(
                  quizId: quizId,
                  quizTitle: quizTitle,
                  questions: questions,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading screen on error
        Navigator.pop(context);

        setState(
          () => _isGenerating = false,
        ); // Ensure state is reset just in case

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? Colors.white70 : const Color(0xFF664C9A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            bottom: true,
            child:
                CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildAppBar(isDark, textMain, textSub),
                        ),
                        SliverToBoxAdapter(
                          child: _buildHeroSection(
                            isDark,
                            surfaceColor,
                            textMain,
                            textSub,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildQuickActions(
                            isDark,
                            surfaceColor,
                            textSub,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildCreateSection(
                            isDark,
                            surfaceColor,
                            textMain,
                            textSub,
                          ),
                        ),
                        SliverToBoxAdapter(child: _buildGenerateButton()),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color textMain, Color textSub) {
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
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF9333EA)],
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
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Q',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                  Text(
                    _userName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1B2E) : Colors.white,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Icon(
                  AdService().isLimitReached()
                      ? Icons.play_circle_filled_rounded
                      : Icons.bolt_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  AdService().isLimitReached()
                      ? 'Ads'
                      : '${AdService().getRemainingFreeQuizzes()} Free',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
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
                      _getGreeting(),
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
                    const TextSpan(text: 'What do you want to\n'),
                    TextSpan(
                      text: 'learn today?',
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  void _handleQuickAction(String label) {
    if (label == 'AI Gen') {
      // Scroll to topic input
      _inputFocusNode.requestFocus();
    } else if (label == 'Quick') {
      // Generate General Knowledge Quiz
      _startGeneration('General Knowledge', 10, 'medium');
    } else if (label == 'Deep') {
      // Focus input for deep dive
      _inputFocusNode.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a topic for a deep dive!'),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (label == 'Study') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
      );
    }
  }

  Widget _buildQuickActions(bool isDark, Color surfaceColor, Color textSub) {
    final quickActions = [
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'AI Gen',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.bolt_rounded,
        'label': 'Quick',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.psychology_rounded,
        'label': 'Deep',
        'color': primaryColor,
      },
      {
        'icon': Icons.school_rounded,
        'label': 'Study',
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

          return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleQuickAction(label);
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

  Widget _buildCreateSection(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
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
                'Create from topic',
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
            controller: _topicController,
            focusNode: _inputFocusNode,
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
              hintText: "Enter a topic (e.g., 'Photosynthesis')",
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
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _listen();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
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

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child:
          GestureDetector(
                onTap: _isGenerating ? null : _handleGenerate,
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
                      if (_isGenerating)
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
                          'Generate Quiz',
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

// ==========================================
// CONFIGURATION SHEET WIDGET
// ==========================================

class _QuizConfigSheet extends StatefulWidget {
  final String topic;
  final Function(int count, String difficulty) onGenerate;

  const _QuizConfigSheet({required this.topic, required this.onGenerate});

  @override
  State<_QuizConfigSheet> createState() => _QuizConfigSheetState();
}

class _QuizConfigSheetState extends State<_QuizConfigSheet> {
  int _questionCount = 10;
  String _difficulty = 'Medium';
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> _counts = [5, 10, 15, 20];

  static const primaryColor = Color(0xFF5B13EC);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Configure Quiz',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Topic: ${widget.topic}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Difficulty Selector
          Text(
            'Difficulty',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _difficulties.map((diff) {
              final isSelected = _difficulty == diff;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = diff),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      diff,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Question Count Selector
          Text(
            'Number of Questions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _counts.map((count) {
              final isSelected = _questionCount == count;
              return GestureDetector(
                onTap: () => setState(() => _questionCount = count),
                child: Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => widget.onGenerate(_questionCount, _difficulty),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                'Start Generating',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
