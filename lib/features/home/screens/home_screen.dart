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
import '../../quiz/screens/screens.dart';
import '../../quiz/screens/study_notes_screen.dart';
import '../../quiz/screens/custom_quiz_creator_screen.dart';
import '../../quiz/screens/mock_test_setup_screen.dart';
import '../../quiz/screens/study_material_entry_screen.dart';
import '../../../shared/widgets/quirzy_mascot.dart';
import '../widgets/home_widgets.dart' hide QuizGenerationLoadingScreen;
import '../../explore/screens/explore_screen.dart';
import '../widgets/home_cards.dart';
import '../widgets/home_sections.dart';
import '../../ai/screens/screens.dart';
import '../providers/home_stats_provider.dart';
import '../../../shared/providers/exam_provider.dart';
import '../../onboarding/screens/exam_selection_screen.dart';
import '../../../shared/services/smart_notification_service.dart';

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
    _onAppOpen();
  }

  Future<void> _onAppOpen() async {
    final svc = SmartNotificationService();
    // Cancel re-engagement — user is active
    await svc.cancelReEngagement();
    // Schedule re-engagement in case user doesn't come back
    await svc.scheduleReEngagement();
    // Streak protection at 9 PM if not studied today
    final prefs = await SharedPreferences.getInstance();
    final lastStudy = prefs.getString('last_study_date') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final studiedToday = lastStudy == today;
    final streak = prefs.getInt('current_streak') ?? 0;
    await svc.scheduleStreakProtection(
      currentStreak: streak,
      studiedToday: studiedToday,
    );
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
    // Check daily quiz limit before generating
    final canGenerate = await ref.read(canGenerateQuizProvider.future);
    
    if (!canGenerate) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Daily Quiz Limit Reached'),
            content: const Text(
              'You\'ve already generated 1 quiz today. Come back tomorrow for your next free quiz, '
              'or upgrade to Pro for unlimited quizzes!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

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

      // Record daily quiz usage after successful generation
      final quizId = result['quizId']?.toString() ?? result['id']?.toString() ?? '';
      final dailyQuizService = ref.read(dailyQuizServiceProvider);
      await dailyQuizService.recordDailyQuizUsage(
        quizId: quizId,
        topic: topic,
      );

      if (mounted) {
        // Remove the loading screen
        Navigator.pop(context);

        _topicController.clear();
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
                        // Live Stats Banner
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
                              child: Consumer(
                                builder: (context, statsRef, _) {
                                  final statsAsync = statsRef.watch(homeStatsProvider);
                                  return statsAsync.when(
                                    data: (stats) => Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildMiniStat(
                                          Icons.local_fire_department_rounded,
                                          '${stats.streak}',
                                          'Streak',
                                          const Color(0xFFF59E0B),
                                          isDark,
                                        ),
                                        Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
                                        _buildMiniStat(
                                          Icons.bolt_rounded,
                                          '${stats.xpToday}',
                                          'XP Today',
                                          const Color(0xFF10B981),
                                          isDark,
                                        ),
                                        Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
                                        _buildMiniStat(
                                          Icons.quiz_rounded,
                                          '${stats.quizzesToday}',
                                          'Quizzes',
                                          primaryColor,
                                          isDark,
                                        ),
                                        Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                                const SizedBox(width: 4),
                                                Text('AI', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                    error: (_, __) => Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildMiniStat(Icons.local_fire_department_rounded, '0', 'Streak', const Color(0xFFF59E0B), isDark),
                                        Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
                                        _buildMiniStat(Icons.bolt_rounded, '0', 'XP Today', const Color(0xFF10B981), isDark),
                                        Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
                                        _buildMiniStat(Icons.quiz_rounded, '0', 'Quizzes', primaryColor, isDark),
                                      ],
                                    ),
                                  );
                                },
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
                        // Exam Context Banner + Quick Start
                        SliverToBoxAdapter(
                          child: Consumer(
                            builder: (context, examRef, _) {
                              final selectedExam = examRef.watch(examProvider);
                              final examTopics = _getExamTopics(selectedExam);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Exam banner
                                  if (selectedExam != null)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamSelectionScreen())),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF5B13EC), Color(0xFF9333EA)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Targeting ${selectedExam.toUpperCase()}',
                                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                                    ),
                                                    Text(
                                                      'Content personalized for your exam',
                                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text('Change', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Exam topic chips
                                  if (examTopics.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                                      child: Text('Quick Practice', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        itemCount: examTopics.length,
                                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                                        itemBuilder: (context, i) {
                                          final topic = examTopics[i];
                                          return GestureDetector(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              _topicController.text = topic;
                                              _handleGenerate();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: primaryColor.withOpacity(0.3)),
                                              ),
                                              child: Text(topic, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
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
                            childAspectRatio: 1.15,
                            children: [
                              CategoryCard(
                                title: 'Mock Test',
                                icon: Icons.assignment_turned_in_rounded,
                                color: const Color(0xFFEF4444),
                                subtitle: 'JEE, NEET, CAT...',
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MockTestSetupScreen()));
                                },
                              ),
                              CategoryCard(
                                title: 'Study Set',
                                icon: Icons.menu_book_rounded,
                                color: const Color(0xFF10B981),
                                subtitle: 'Summary + Flashcards',
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyMaterialEntryScreen()));
                                },
                              ),
                              CategoryCard(
                                title: 'AI Quiz',
                                icon: Icons.auto_awesome_rounded,
                                color: const Color(0xFF5B13EC),
                                subtitle: 'Any Topic',
                                isDark: isDark,
                                onTap: _showTopicInputDialog,
                              ),
                              CategoryCard(
                                title: 'Explore',
                                icon: Icons.explore_rounded,
                                color: const Color(0xFF3B82F6),
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
      HapticFeedback.lightImpact();
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyNotesScreen()));
    } else if (label == 'Create') {
      HapticFeedback.lightImpact();
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomQuizCreatorScreen()));
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

  List<String> _getExamTopics(String? exam) {
    const topics = {
      'jee': ['Kinematics', 'Thermodynamics', 'Organic Chemistry', 'Calculus', 'Optics'],
      'neet': ['Cell Biology', 'Human Physiology', 'Genetics', 'Organic Chemistry', 'Mechanics'],
      'cat': ['Percentages', 'Reading Comprehension', 'Syllogisms', 'Geometry', 'Time & Work'],
      'cuet': ['English Grammar', 'General Awareness', 'Reasoning', 'Maths Basics'],
      'mba': ['Data Interpretation', 'Critical Reasoning', 'Sentence Correction'],
      'gre': ['Vocabulary', 'Quantitative Reasoning', 'Analytical Writing'],
      'gmat': ['Critical Reasoning', 'Data Sufficiency', 'Sentence Correction'],
      'ielts': ['Reading Skills', 'Grammar', 'Academic Vocabulary'],
      '10th': ['Algebra', 'Trigonometry', 'Chemistry Basics', 'Biology Basics'],
      '12th': ['Integration', 'Electrostatics', 'Chemical Bonding', 'Human Reproduction'],
    };
    if (exam == null) return [];
    return topics[exam.toLowerCase()] ?? [];
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
