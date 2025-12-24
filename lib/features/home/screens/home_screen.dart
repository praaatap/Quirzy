import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';
import 'package:quirzy/service/ad_service.dart';
import 'package:quirzy/features/quiz/screens/start_quiz_screen.dart';
import 'package:quirzy/core/platform/platform_adaptive.dart';

// ==========================================
// PREMIUM HOME SCREEN
// ==========================================
// Responsive design for all Android screen sizes
// Features: Adaptive layouts, smooth animations, modern UI

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _quizIdeaController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isGenerating = false;
  int _remainingFree = 0;
  String? _selectedQuickTopic;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  bool get wantKeepAlive => true;

  // Quick topic suggestions with gradients
  static const List<Map<String, dynamic>> _quickTopics = [
    {
      'icon': '🔬',
      'topic': 'Science',
      'colors': [Color(0xFF4CAF50), Color(0xFF81C784)],
    },
    {
      'icon': '📐',
      'topic': 'Math',
      'colors': [Color(0xFF2196F3), Color(0xFF64B5F6)],
    },
    {
      'icon': '🌍',
      'topic': 'Geography',
      'colors': [Color(0xFFFF9800), Color(0xFFFFB74D)],
    },
    {
      'icon': '📚',
      'topic': 'History',
      'colors': [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    },
    {
      'icon': '💻',
      'topic': 'Tech',
      'colors': [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
    },
    {
      'icon': '🎨',
      'topic': 'Art',
      'colors': [Color(0xFFE91E63), Color(0xFFF06292)],
    },
    {
      'icon': '🧬',
      'topic': 'Biology',
      'colors': [Color(0xFF8BC34A), Color(0xFFAED581)],
    },
    {
      'icon': '⚛️',
      'topic': 'Physics',
      'colors': [Color(0xFF673AB7), Color(0xFF9575CD)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAdInfo();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();
  }

  Future<void> _loadAdInfo() async {
    await AdService().initialize();
    _refreshRemainingCount();
  }

  void _refreshRemainingCount() {
    if (!mounted) return;
    setState(() => _remainingFree = AdService().getRemainingFreeQuizzes());
  }

  @override
  void dispose() {
    _quizIdeaController.dispose();
    _inputFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _selectQuickTopic(String topic) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedQuickTopic == topic) {
        _selectedQuickTopic = null;
        _quizIdeaController.clear();
      } else {
        _selectedQuickTopic = topic;
        _quizIdeaController.text = topic;
      }
    });
  }

  Future<void> _handleGeneratePress() async {
    _inputFocusNode.unfocus();
    HapticFeedback.mediumImpact();

    if (_quizIdeaController.text.trim().isEmpty) {
      _showSnackBar('Please enter a topic or select one below', isError: true);
      return;
    }

    if (AdService().isLimitReached()) {
      _showAdConfirmationDialog();
    } else {
      await _generateQuiz();
    }
  }

  Future<void> _playAdAndGenerate() async {
    await AdService().showRewardedAd(
      onRewardEarned: () async => await _generateQuiz(),
      onAdFailed: () =>
          _showSnackBar('Ad failed to load. Check connection.', isError: true),
    );
  }

  Future<void> _generateQuiz() async {
    if (!mounted) return;
    setState(() => _isGenerating = true);

    try {
      final quizService = ref.read(quizServiceProvider);
      final result = await quizService.generateQuiz(
        _quizIdeaController.text.trim(),
        questionCount: 15,
      );

      await AdService().incrementQuizCount();
      _refreshRemainingCount();

      if (!mounted) return;
      setState(() => _isGenerating = false);

      if (result['questions'] == null || result['questions'].isEmpty) {
        _showErrorDialog('No questions generated. Try a simpler topic.');
        return;
      }

      final questions = List<Map<String, dynamic>>.from(result['questions']);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => StartQuizScreen(
            quizId: result['quizId'].toString(),
            quizTitle: result['title'] ?? _quizIdeaController.text.trim(),
            questions: questions,
            difficulty: null,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.03, 0),
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

      _quizIdeaController.clear();
      setState(() => _selectedQuickTopic = null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showErrorDialog('Error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
        ),
        title: Text(
          'Oops!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.movie_filter_rounded,
            size: 40,
            color: Colors.amber,
          ),
        ),
        title: Text(
          'Free Limit Reached',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Watch a short ad to generate this quiz?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _playAdAndGenerate();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              'Watch Ad',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isLargeScreen = size.width > 400;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          const RepaintBoundary(child: _BackgroundDecoration()),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  physics: PlatformAdaptive.scrollPhysics,
                  slivers: [
                    // App Bar
                    _buildAppBar(theme, isSmallScreen),

                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Hero Section
                          _buildHeroSection(
                            theme,
                            isSmallScreen,
                            isLargeScreen,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 28),

                          // Quick Topics
                          _buildSectionTitle('Quick Topics', theme),
                          const SizedBox(height: 12),
                          _buildQuickTopics(theme, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 20 : 28),

                          // Input Area
                          _buildInputSection(theme),
                          SizedBox(height: isSmallScreen ? 18 : 24),

                          // Generate Button
                          _buildGenerateButton(theme),

                          const SizedBox(height: 120),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD METHODS
  // ==========================================

  Widget _buildAppBar(ThemeData theme, bool isSmall) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: isSmall ? 60 : 68,
      title: Row(
        children: [
          // Premium animated logo
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withBlue(220),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isSmall ? 14 : 16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: isSmall ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmall ? 12 : 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quirzy',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: isSmall ? 22 : 26,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'AI Quiz Generator',
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 10 : 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _QuotaBadge(remainingFree: _remainingFree, isSmall: isSmall),
        SizedBox(width: isSmall ? 12 : 16),
      ],
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isSmall, bool isLarge) {
    // Dynamic greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting row with animated wave
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.6),
                theme.colorScheme.primaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                greetingIcon,
                size: isSmall ? 18 : 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                greeting,
                style: GoogleFonts.poppins(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text('👋', style: TextStyle(fontSize: isSmall ? 14 : 16)),
            ],
          ),
        ),
        SizedBox(height: isSmall ? 16 : 20),

        // Main headline with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              theme.colorScheme.onSurface,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ).createShader(bounds),
          child: Text(
            'What do you want\nto learn today?',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 28 : (isLarge ? 34 : 32),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
              letterSpacing: -1,
            ),
          ),
        ),
        SizedBox(height: isSmall ? 16 : 20),

        // Premium feature badges
        Row(
          children: [
            _PremiumFeatureBadge(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              gradient: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withBlue(220),
              ],
            ),
            const SizedBox(width: 10),
            _PremiumFeatureBadge(
              icon: Icons.bolt_rounded,
              label: 'Fast',
              gradient: [Colors.orange, Colors.deepOrange],
            ),
            const SizedBox(width: 10),
            _PremiumFeatureBadge(
              icon: Icons.psychology_alt_rounded,
              label: 'Smart',
              gradient: [Colors.purple, Colors.deepPurple],
            ),
            const SizedBox(width: 10),
            _PremiumFeatureBadge(
              icon: Icons.school_rounded,
              label: 'Learn',
              gradient: [Colors.teal, Colors.cyan],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.outline.withOpacity(0.3),
                  theme.colorScheme.outline.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTopics(ThemeData theme, bool isSmall) {
    return SizedBox(
      height: isSmall ? 38 : 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _quickTopics.length,
        separatorBuilder: (_, __) => SizedBox(width: isSmall ? 8 : 10),
        itemBuilder: (context, index) {
          final topic = _quickTopics[index];
          final isSelected = _selectedQuickTopic == topic['topic'];
          final colors = topic['colors'] as List<Color>;

          return _QuickTopicChip(
            icon: topic['icon'] as String,
            label: topic['topic'] as String,
            colors: colors,
            isSelected: isSelected,
            isSmall: isSmall,
            onTap: () => _selectQuickTopic(topic['topic'] as String),
          );
        },
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return _ModernInputArea(
      controller: _quizIdeaController,
      focusNode: _inputFocusNode,
      isGenerating: _isGenerating,
      onChanged: () {
        if (_selectedQuickTopic != null &&
            _quizIdeaController.text != _selectedQuickTopic) {
          setState(() => _selectedQuickTopic = null);
        }
      },
    );
  }

  Widget _buildGenerateButton(ThemeData theme) {
    return _GenerateButton(
      isGenerating: _isGenerating,
      isLimitReached: AdService().isLimitReached(),
      onPressed: _handleGeneratePress,
    );
  }
}

// ==========================================
// WIDGETS
// ==========================================

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Top gradient overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 450,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.14),
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.05 : 0.08),
                  theme.scaffoldBackgroundColor.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // Top-right primary blur blob
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.25),
                  theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.12),
                  theme.colorScheme.primary.withOpacity(0),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 100,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        // Bottom-left secondary blur blob
        Positioned(
          bottom: 180,
          left: -120,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.12 : 0.15),
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.06 : 0.08),
                  theme.colorScheme.secondary.withOpacity(0),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  blurRadius: 80,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
        // Accent glow
        Positioned(
          top: size.height * 0.35,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.teal.withOpacity(isDark ? 0.1 : 0.12),
                  Colors.teal.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Premium feature badge with gradient for hero section
class _PremiumFeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  const _PremiumFeatureBadge({
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  final int remainingFree;
  final bool isSmall;

  const _QuotaBadge({required this.remainingFree, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCredits = remainingFree > 0;
    bool isDarkTheme = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 14,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCredits
              ? [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.8),
                ]
              : [Colors.amber.withOpacity(0.3), Colors.amber.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCredits
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.amber.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasCredits ? Icons.bolt_rounded : Icons.movie_rounded,
            size: isSmall ? 14 : 16,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            hasCredits ? '$remainingFree free' : 'Ad',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTopicChip extends StatelessWidget {
  final String icon;
  final String label;
  final List<Color> colors;
  final bool isSelected;
  final bool isSmall;
  final VoidCallback onTap;

  const _QuickTopicChip({
    required this.icon,
    required this.label,
    required this.colors,
    required this.isSelected,
    required this.isSmall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 14,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: colors) : null,
          color: isSelected
              ? null
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.first
                : theme.colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: isSmall ? 14 : 16)),
            SizedBox(width: isSmall ? 5 : 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 12 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernInputArea extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGenerating;
  final VoidCallback? onChanged;

  const _ModernInputArea({
    required this.controller,
    required this.focusNode,
    required this.isGenerating,
    this.onChanged,
  });

  @override
  State<_ModernInputArea> createState() => _ModernInputAreaState();
}

class _ModernInputAreaState extends State<_ModernInputArea> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
      widget.onChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: !widget.isGenerating,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 5,
      style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
      decoration: InputDecoration(
        hintText: 'Enter a topic or paste your notes...',
        hintStyle: GoogleFonts.poppins(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  widget.controller.clear();
                  HapticFeedback.lightImpact();
                },
                icon: Icon(
                  Icons.clear_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool isGenerating;
  final bool isLimitReached;
  final VoidCallback onPressed;

  const _GenerateButton({
    required this.isGenerating,
    required this.isLimitReached,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Full width to match text field
    return SizedBox(
      height: 54, // Slightly taller for better touch target
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isLimitReached
                ? [Colors.amber, Colors.orange]
                : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withBlue(200),
                  ],
          ),
          boxShadow: isGenerating
              ? null
              : [
                  BoxShadow(
                    color:
                        (isLimitReached
                                ? Colors.amber
                                : theme.colorScheme.primary)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isGenerating ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isLimitReached
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Creating...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLimitReached
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLimitReached
                              ? Icons.play_circle_rounded
                              : Icons.auto_awesome_rounded,
                          size: 20,
                          color: isLimitReached ? Colors.black87 : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLimitReached ? 'Watch Ad' : 'Generate',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isLimitReached
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
