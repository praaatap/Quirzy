import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../quiz/providers/quiz_providers.dart';
import '../../quiz/screens/start_quiz_screen.dart';
import '../../shared/widgets/quirzy_mascot.dart';
import '../widgets/home_widgets.dart';
import '../../explore/screens/explore_screen.dart';
import '../widgets/home_cards.dart';
import '../widgets/home_sections.dart';
import '../../ai/screens/insights_screen.dart';

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
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  String _userName = 'Quiz Master';
  String? _photoUrl;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initAnimations();
    _speech = stt.SpeechToText();
    _initAdService();
  }

  Future<void> _initAdService() async {
    // AdService from stubs doesn't have initialize yet, stubing it out or removing if not in stub
    // await AdService().initialize();
    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read(key: 'user_name');
    final photoUrl = await _storage.read(key: 'user_photo_url');
    if (mounted) {
      setState(() {
        if (name != null) _userName = name;
        _photoUrl = photoUrl;
      });
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
    final localizations = AppLocalizations.of(context)!;
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
        if (!mounted) return;
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
                      localizations.listening,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastWords.isEmpty
                          ? localizations.sayYourTopic
                          : _lastWords,
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
            SnackBar(content: Text(localizations.speechNotAvailable)),
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
    final localizations = AppLocalizations.of(context)!;
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.pleaseEnterTopic,
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
      builder: (context) => QuizConfigSheet(
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
        topic: topic,
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
            content: Text(
              '${AppLocalizations.of(context)!.failedToGenerate}$e',
            ),
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
                          child: HomeAppBar(
                            userName: _userName,
                            photoUrl: _photoUrl,
                            greeting: _getGreeting(),
                            textMain: textMain,
                            textSub: textSub,
                            primaryColor: primaryColor,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: HomeHeroSection(
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            textMain: textMain,
                            textSub: textSub,
                            primaryColor: primaryColor,
                            greeting: _getGreeting(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: QuickActions(
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            textSub: textSub,
                            onAction: _handleQuickAction,
                          ),
                        ),
                        // Compact Stats Banner
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.1),
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMiniStat(
                                    Icons.local_fire_department_rounded,
                                    '7',
                                    'Streak',
                                    const Color(0xFFF59E0B),
                                    isDark,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                  _buildMiniStat(
                                    Icons.bolt_rounded,
                                    '150',
                                    'XP Today',
                                    const Color(0xFF10B981),
                                    isDark,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                  _buildMiniStat(
                                    Icons.quiz_rounded,
                                    '3',
                                    'Quizzes',
                                    primaryColor,
                                    isDark,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                  // AI Insights Button
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const InsightsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF8B5CF6),
                                            Color(0xFFEC4899),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'AI',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: TopicInputSection(
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            textMain: textMain,
                            textSub: textSub,
                            controller: _topicController,
                            focusNode: _inputFocusNode,
                            onMicTap: _listen,
                            primaryColor: primaryColor,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: GenerateQuizButton(
                            isGenerating: _isGenerating,
                            onTap: _handleGenerate,
                            primaryColor: primaryColor,
                          ),
                        ),
                        // Quick Categories Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                            child: Text(
                              'Quick Start',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              CategoryCard(
                                title: 'AI Quiz',
                                icon: Icons.auto_awesome_rounded,
                                color: const Color(0xFF5B13EC),
                                subtitle: 'Custom Topics',
                                isDark: isDark,
                                onTap: _showTopicInputDialog,
                              ),
                              CategoryCard(
                                title: 'Coding',
                                icon: Icons.code_rounded,
                                color: const Color(0xFF3B82F6),
                                subtitle: 'Programming',
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExploreScreen(),
                                  ),
                                ),
                              ),
                              CategoryCard(
                                title: 'Aptitude',
                                icon: Icons.calculate_rounded,
                                color: const Color(0xFFF59E0B),
                                subtitle: 'Math & Logic',
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExploreScreen(),
                                  ),
                                ),
                              ),
                              CategoryCard(
                                title: 'Explore',
                                icon: Icons.explore_rounded,
                                color: const Color(0xFF10B981),
                                subtitle: 'All Topics',
                                isDark: isDark,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExploreScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Featured Quizzes',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ExploreScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'See All',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                              bottom: 12,
                            ),
                            child: Text(
                              'Curated quizzes to boost your skills',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSub,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 170,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              children: [
                                _buildPremiumFeaturedCard(
                                  title: 'Daily Challenge',
                                  subtitle: 'New questions every day',
                                  count: '5 Qs',
                                  gradient: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                                  icon: Icons.bolt_rounded,
                                  isNew: true,
                                ),
                                _buildPremiumFeaturedCard(
                                  title: 'Speed Math',
                                  subtitle: 'Quick calculations',
                                  count: '20 Qs',
                                  gradient: [
                                    const Color(0xFFF59E0B),
                                    const Color(0xFFEF4444),
                                  ],
                                  icon: Icons.timer_rounded,
                                  isNew: false,
                                ),
                                _buildPremiumFeaturedCard(
                                  title: 'Verbal Mastery',
                                  subtitle: 'English vocabulary',
                                  count: '15 Qs',
                                  gradient: [
                                    const Color(0xFF10B981),
                                    const Color(0xFF14B8A6),
                                  ],
                                  icon: Icons.auto_stories_rounded,
                                  isNew: false,
                                ),
                                _buildPremiumFeaturedCard(
                                  title: 'Logic & Reasoning',
                                  subtitle: 'Brain teasers',
                                  count: '10 Qs',
                                  gradient: [
                                    const Color(0xFFEC4899),
                                    const Color(0xFF8B5CF6),
                                  ],
                                  icon: Icons.psychology_rounded,
                                  isNew: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
          // Quirzy Mascot - Floating companion in bottom right corner
          SafeArea(
            child: FloatingCompanion(
              alignment: Alignment.bottomRight,
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context)!;
    if (hour < 12) return localizations.greetingMorning;
    if (hour < 17) return localizations.greetingAfternoon;
    return localizations.greetingEvening;
  }

  void _handleQuickAction(String label) {
    if (label == 'AI Gen') {
      _inputFocusNode.requestFocus();
    } else if (label == 'Quick') {
      _startGeneration('General Knowledge', 10, 'medium');
    } else if (label == 'Study') {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const StudyInputScreen()));
      // StudyInputScreen seems missing or renamed
    }
  }

  void _showTopicInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create Custom Quiz ✨',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter topic (e.g. "Photosynthesis")',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _showQuizConfigurationDialog(controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B13EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Next',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturedCard({
    required String title,
    required String subtitle,
    required String count,
    required List<Color> gradient,
    required IconData icon,
    required bool isNew,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _topicController.text = title;
        _showQuizConfigurationDialog(title);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          count,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: gradient[0],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
