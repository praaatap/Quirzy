import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/core/theme/app_theme.dart';
import 'package:quirzy/features/flashcards/services/flashcard_service.dart';
import 'package:quirzy/features/flashcards/services/flashcard_cache_service.dart';
import 'package:quirzy/features/flashcards/screens/flashcard_study_screen.dart';
import 'package:quirzy/core/widgets/loading/shimmer_loading.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _flashcardSets = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isFromCache = false;

  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await FlashcardCacheService.init();
    await _loadFlashcardSets();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _pulseAnim = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
    _animController.forward();
  }

  Future<void> _loadFlashcardSets({bool forceRefresh = false}) async {
    try {
      final sets = await FlashcardService.getFlashcardSets(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _flashcardSets = sets;
        _isLoading = false;
        _isFromCache = !forceRefresh && FlashcardCacheService.getCachedFlashcardSets() != null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateFlashcards() async {
    if (_topicController.text.trim().isEmpty) {
      _showSnackBar('Please enter a topic', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    _focusNode.unfocus();
    setState(() => _isGenerating = true);

    try {
      final result = await FlashcardService.generateFlashcards(
        _topicController.text.trim(),
        cardCount: 10,
      );

      if (!mounted) return;
      setState(() => _isGenerating = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlashcardStudyScreen(
            setId: result['id'],
            title: result['title'] ?? _topicController.text,
            cards: List<Map<String, dynamic>>.from(result['cards'] ?? []),
          ),
        ),
      ).then((_) => _loadFlashcardSets());

      _topicController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final quizColors = context.quizColors;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? quizColors.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _openFlashcardSet(Map<String, dynamic> set) async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      ),
    );

    try {
      final fullSet = await FlashcardService.getFlashcardSet(set['id']);
      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlashcardStudyScreen(
            setId: fullSet['id'],
            title: fullSet['title'],
            cards: List<Map<String, dynamic>>.from(fullSet['cards'] ?? []),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Failed to load flashcards', isError: true);
    }
  }

  Future<void> _deleteSet(int setId) async {
    try {
      await FlashcardService.deleteFlashcardSet(setId);
      _loadFlashcardSets();
      _showSnackBar('Set deleted');
    } catch (e) {
      _showSnackBar('Failed to delete', isError: true);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final quizColors = context.quizColors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient
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
              child: RefreshIndicator(
                onRefresh: () => _loadFlashcardSets(forceRefresh: true),
                color: theme.colorScheme.primary,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          // Top Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.style_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Flashcards',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (_isFromCache)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: quizColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: quizColors.warning.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.offline_bolt_rounded, size: 14, color: quizColors.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Offline',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: quizColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Hero Title
                          Text(
                            'Study Smarter\nWith AI',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Filter Pills (matched to screenshot: only 2 chips)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'AI-Generated',
                                  icon: Icons.auto_awesome,
                                  isActive: true,
                                  theme: theme,
                                ),
                                const SizedBox(width: 12),
                                _FilterChip(
                                  label: 'Quick Study',
                                  icon: Icons.bolt,
                                  isActive: false,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Search Bar
                          _SearchGenerateBar(
                            controller: _topicController,
                            focusNode: _focusNode,
                            isGenerating: _isGenerating,
                            onGenerate: _generateFlashcards,
                            theme: theme,
                          ),
                          const SizedBox(height: 20),
                          // Generate Button with pulse
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _isGenerating ? null : _generateFlashcards,
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                ),
                                icon: _isGenerating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.auto_awesome_rounded),
                                label: Text(
                                  _isGenerating ? 'Generating...' : 'Generate',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // My Sets Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'My Sets',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_flashcardSets.length}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    // List or Empty State
                    if (_isLoading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ShimmerPlaceholders.historyList(itemCount: 3),
                        ),
                      )
                    else if (_flashcardSets.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState(theme))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final set = _flashcardSets[index];
                              return _FlashcardSetCard(
                                key: ValueKey(set['id']), // Stable keys for perf
                                set: set,
                                onTap: () => _openFlashcardSet(set),
                                onDelete: () => _deleteSet(set['id']),
                              );
                            },
                            childCount: _flashcardSets.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star_rounded, size: 28, color: Colors.amber),
                SizedBox(width: 4),
                Icon(Icons.star_rounded, size: 28, color: Colors.amber),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Flashcard Sets Yet',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a topic above to generate your\nfirst AI-powered flashcards!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Sub-widgets (unchanged, but const-enabled)
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.theme,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchGenerateBar extends StatelessWidget {
  const _SearchGenerateBar({
    required this.controller,
    required this.focusNode,
    required this.isGenerating,
    required this.onGenerate,
    required this.theme,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isGenerating,
              decoration: InputDecoration(
                hintText: 'Enter a topic e.g. Biology, History',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => onGenerate(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardSetCard extends StatelessWidget {
  const _FlashcardSetCard({
    required Key? key,
    required this.set,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  final Map<String, dynamic> set;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardCount = set['cardCount'] ?? set['cards']?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.style_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(
          set['title'] ?? 'Untitled',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$cardCount cards'),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
      ),
    );
  }
}
