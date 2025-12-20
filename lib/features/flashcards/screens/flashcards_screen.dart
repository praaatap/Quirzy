import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/features/flashcards/services/flashcard_service.dart';
import 'package:quirzy/features/flashcards/services/flashcard_cache_service.dart';
import 'package:quirzy/features/flashcards/screens/flashcard_study_screen.dart';
import 'package:quirzy/shared/widgets/loading/shimmer_loading.dart';
import 'package:timeago/timeago.dart' as timeago;

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  final TextEditingController _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _flashcardSets = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  bool _isFromCache = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Quick topic suggestions
  final List<String> _suggestions = [
    '🇪🇸 Spanish Basics',
    '🧮 Math Formulas',
    '🧬 Biology Terms',
    '💻 Programming',
    '📜 History Facts',
    '🌍 Geography',
  ];

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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  Future<void> _loadFlashcardSets({bool forceRefresh = false}) async {
    try {
      final sets = await FlashcardService.getFlashcardSets(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _flashcardSets = sets;
        _isLoading = false;
        _error = null;
        _isFromCache =
            !forceRefresh &&
            FlashcardCacheService.getCachedFlashcardSets() != null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
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

      // Navigate to study screen
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
      _showSnackBar('✨ Flashcards created!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _openFlashcardSet(Map<String, dynamic> set) async {
    HapticFeedback.lightImpact();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.purple)),
    );

    try {
      final fullSet = await FlashcardService.getFlashcardSet(set['id']);
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

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
      Navigator.pop(context); // Dismiss loading
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background
          _BackgroundDecoration(isDark: isDark),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: () => _loadFlashcardSets(forceRefresh: true),
                color: Colors.purple,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.purple,
                                        Colors.deepPurple,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.style_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Flashcards',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (_isFromCache)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.offline_bolt_rounded,
                                              size: 12,
                                              color: Colors.orange.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Offline mode',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.orange.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Subtitle
                            Text(
                              'Learn smarter with AI-powered flashcards',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Generate Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: _GenerateCard(
                          controller: _topicController,
                          focusNode: _focusNode,
                          isGenerating: _isGenerating,
                          onGenerate: _generateFlashcards,
                          suggestions: _suggestions,
                          onSuggestionTap: (suggestion) {
                            _topicController.text = suggestion
                                .replaceAll(
                                  RegExp(
                                    r'[\u{1F1E0}-\u{1F9FF}]',
                                    unicode: true,
                                  ),
                                  '',
                                )
                                .trim();
                            _generateFlashcards();
                          },
                        ),
                      ),
                    ),

                    // My Sets Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.folder_rounded,
                                color: Colors.purple,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'My Sets',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_flashcardSets.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sets List
                    if (_isLoading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ShimmerPlaceholders.historyList(itemCount: 3),
                        ),
                      )
                    else if (_error != null && _flashcardSets.isEmpty)
                      SliverToBoxAdapter(child: _buildErrorState(theme))
                    else if (_flashcardSets.isEmpty)
                      SliverToBoxAdapter(child: _buildEmptyState(theme))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final set = _flashcardSets[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 60),
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: _FlashcardSetCard(
                                set: set,
                                onTap: () => _openFlashcardSet(set),
                                onDelete: () => _deleteSet(set['id']),
                              ),
                            );
                          }, childCount: _flashcardSets.length),
                        ),
                      ),

                    // Bottom padding
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

  Widget _buildErrorState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connection Issue',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unable to load flashcards',
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _loadFlashcardSets(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.15),
                  Colors.deepPurple.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 52,
              color: Colors.purple.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Flashcard Sets Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a topic above to generate\nyour first AI-powered flashcards!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  final bool isDark;

  const _BackgroundDecoration({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const _GenerateCard({
    required this.controller,
    required this.focusNode,
    required this.isGenerating,
    required this.onGenerate,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withOpacity(0.3)
                : theme.colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field
              TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isGenerating,
                style: GoogleFonts.poppins(fontSize: 16),
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onGenerate(),
                decoration: InputDecoration(
                  hintText: 'What do you want to learn?',
                  hintStyle: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.purple.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),

              // Quick suggestions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions
                      .map(
                        (s) => GestureDetector(
                          onTap: isGenerating ? null : () => onSuggestionTap(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.1,
                                ),
                              ),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Generate button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: isGenerating ? null : onGenerate,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple,
                      disabledBackgroundColor: Colors.purple.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Generating...',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Generate Flashcards',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardSetCard extends StatelessWidget {
  final Map<String, dynamic> set;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FlashcardSetCard({
    required this.set,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardCount = set['cardCount'] ?? set['cards']?.length ?? 0;
    final createdAt = set['createdAt'] != null
        ? DateTime.parse(set['createdAt'])
        : DateTime.now();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withOpacity(0.3)
                : theme.colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade300,
                            Colors.deepPurple.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            set['title'] ?? 'Untitled',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.layers_rounded,
                                size: 14,
                                color: Colors.purple.shade300,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$cardCount cards',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  timeago.format(createdAt),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.5,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Delete Set?',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                'This action cannot be undone.',
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    onDelete();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
