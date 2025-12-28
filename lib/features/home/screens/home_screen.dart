import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/features/quiz/screens/start_quiz_screen.dart';
import 'package:quirzy/features/quiz/services/quiz_service.dart';
import 'package:quirzy/core/services/ad_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _quizIdeaController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isGenerating = false;
  int _remainingFree = 0;
  
  // Kept for logic, but we won't strictly select them in the UI anymore to match the new design
  String? _selectedQuickTopic; 

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  bool get wantKeepAlive => true;

  // Using your existing data structure, but will render as "Recent/Quick" list
  static const List<Map<String, dynamic>> _quickTopics = [
    {'icon': '🔬', 'topic': 'Science', 'colors': [Color(0xFF4CAF50), Color(0xFF81C784)]},
    {'icon': '📐', 'topic': 'Math', 'colors': [Color(0xFF2196F3), Color(0xFF64B5F6)]},
    {'icon': '🌍', 'topic': 'Geography', 'colors': [Color(0xFFFF9800), Color(0xFFFFB74D)]},
    {'icon': '💻', 'topic': 'Tech', 'colors': [Color(0xFF00BCD4), Color(0xFF4DD0E1)]},
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
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
        ));

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

  // Logic to populate text field from list
  void _selectQuickTopic(String topic) {
    HapticFeedback.selectionClick();
    _quizIdeaController.text = topic;
    _handleGeneratePress();
  }

  Future<void> _handleGeneratePress() async {
    _inputFocusNode.unfocus();
    HapticFeedback.mediumImpact();

    if (_quizIdeaController.text.trim().isEmpty) {
      _showSnackBar('Please enter a topic', isError: true);
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
          _showSnackBar('Ad failed to load.', isError: true),
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
          pageBuilder: (_, __, ___) => StartQuizScreen(
            quizId: result['quizId'].toString(),
            quizTitle: result['title'] ?? _quizIdeaController.text.trim(),
            questions: questions,
            difficulty: null,
          ),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );

      _quizIdeaController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showErrorDialog('Error generating quiz. Please try again.');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
        backgroundColor: isError ? context.quizColors.error : context.theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oops'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _showAdConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text('Watch a short ad to generate another quiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _playAdAndGenerate();
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.theme;
    final quizColors = context.quizColors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle top gradient (Clean, no blobs)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.scaffoldBackgroundColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 20),
                          
                          // 1. Header (Logo + Free Badge)
                          _buildHeader(theme, quizColors),
                          
                          const SizedBox(height: 24),

                          // 2. Greeting Pill
                          _buildGreetingPill(theme),

                          const SizedBox(height: 24),

                          // 3. Hero Text (Gradient)
                          _buildHeroText(theme),

                          const SizedBox(height: 32),

                          // 4. Feature Circles (AI, Fast, Smart, Learn)
                          _buildFeatureRow(theme, quizColors),

                          const SizedBox(height: 32),

                          // 5. Input Card (White box, big input, mic/image icons)
                          _buildCreationCard(theme, quizColors),

                          const SizedBox(height: 24),

                          // 6. Generate Button
                          _buildGenerateButton(theme),

                          const SizedBox(height: 32),

                          // 7. Recent Generations (Using _quickTopics as data source)
                          _buildRecentSection(theme),

                          const SizedBox(height: 120), // Bottom padding
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

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(ThemeData theme, QuizColors quizColors) {
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.bolt_rounded, color: theme.colorScheme.onPrimary, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quirzy',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            Text(
              'AI Quiz Generator',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Free Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                '$_remainingFree free',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingPill(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nightlight_round, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Good Evening',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to',
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ).createShader(bounds),
          child: Text(
            'learn today?',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white, // Required for ShaderMask
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(ThemeData theme, QuizColors quizColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FeatureCircle(
          icon: Icons.auto_awesome,
          label: 'AI',
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        _FeatureCircle(
          icon: Icons.bolt_rounded,
          label: 'Fast',
          color: quizColors.warning, // Orange
          theme: theme,
        ),
        _FeatureCircle(
          icon: Icons.psychology,
          label: 'Smart',
          color: theme.colorScheme.secondary, // Purple/Indigo
          theme: theme,
        ),
        _FeatureCircle(
          icon: Icons.school,
          label: 'Learn',
          color: quizColors.success, // Teal/Green
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildCreationCard(ThemeData theme, QuizColors quizColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create from topic',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160, // Fixed height for text area
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _inputFocusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    decoration: InputDecoration(
                      hintText:
                          "Enter a topic or paste your notes here...\ne.g., 'Photosynthesis process' or 'History of Rome'",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _IconAction(
                      icon: Icons.mic_rounded,
                      theme: theme,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        // Placeholder for voice logic
                      },
                    ),
                    const SizedBox(width: 12),
                    _IconAction(
                      icon: Icons.image_rounded,
                      theme: theme,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        // Placeholder for image logic
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _handleGeneratePress,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
        ),
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome, size: 20),
        label: Text(
          _isGenerating ? 'Generating...' : 'Generate Quiz',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent generations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Rendering the _quickTopics list as if they were recent items
        // to match the UI visual style requested.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quickTopics.length,
          itemBuilder: (context, index) {
            final topic = _quickTopics[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _selectQuickTopic(topic['topic'] as String),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (topic['colors'] as List<Color>)[0].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          topic['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic['topic'] as String,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to generate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- SUB WIDGETS ---

class _FeatureCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  const _FeatureCircle({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Clean background for icon
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Icon(
          icon,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}