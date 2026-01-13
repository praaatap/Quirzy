import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../home/widgets/home_widgets.dart';
import '../providers/flashcard_providers.dart';
import '../widgets/flashcard_widgets.dart';
import '../../shared/providers/exam_provider.dart';
import '../../onboarding/screens/exam_selection_screen.dart';

// ==========================================
// REDESIGNED FLASHCARDS SCREEN
// Full Dark/Light Theme Support
// ==========================================

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _flashcardSets = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  int _selectedTab = 0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _userName = 'Quiz Master';
  String? _photoUrl;

  // Static colors
  static const primaryColor = Color(0xFF5B13EC);
  static const primaryLight = Color(0xFFEFE9FD);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // FlashcardCacheService.init() is optional - Hive handles this via main.dart
    await _loadFlashcardSets();
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

  Future<void> _loadFlashcardSets({bool forceRefresh = false}) async {
    try {
      final flashcardService = ref.read(flashcardServiceProvider);
      final sets = await flashcardService.getMyFlashcardSets();
      if (!mounted) return;
      setState(() {
        _flashcardSets = sets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateFlashcards() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      HapticFeedback.heavyImpact();
      _showSnackBar('Please enter a topic', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    _focusNode.unfocus();

    // Check daily limit (53 free flashcards per day)
    final adService = AdService();
    if (!adService.isFlashcardLimitReached()) {
      // Still have free flashcards
      adService.incrementFlashcardCount();
      _startFlashcardGeneration(topic);
    } else {
      // Limit reached - show ad
      adService.showRewardedAd(
        onRewardEarned: () {
          if (mounted) {
            _startFlashcardGeneration(topic);
          }
        },
        onAdFailed: () {
          // Fallback: Proceed even if ad fails
          if (mounted) {
            _startFlashcardGeneration(topic);
          }
        },
      );
    }
  }

  Future<void> _startFlashcardGeneration(String topic) async {
    // Show AI Generation Loading Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizGenerationLoadingScreen(
          title: 'Creating Flashcards...',
          subtitle: 'AI is distilling key concepts\ninto bite-sized cards.',
        ),
      ),
    );

    try {
      final flashcardService = ref.read(flashcardServiceProvider);
      final result = await flashcardService.generateFlashcards(
        topic: topic,
        cardCount: 10,
      );

      if (!mounted) return;

      // Pop loading screen
      Navigator.pop(context);

      _topicController.clear();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FlashcardStudyScreen(
                setId: result['id'],
                title: result['title'] ?? topic,
                cards: List<Map<String, dynamic>>.from(result['cards'] ?? []),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      ).then((_) => _loadFlashcardSets());
    } catch (e) {
      if (!mounted) return;
      // Pop loading screen on error
      Navigator.pop(context);
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _openFlashcardSet(Map<String, dynamic> set) async {
    HapticFeedback.lightImpact();
    if (!mounted) return;

    // Check for Premium Sets (Mock ID usage)
    if (set['isPremium'] == true) {
      _showPremiumDialog(set['title']);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      final flashcardService = ref.read(flashcardServiceProvider);
      final fullSet = await flashcardService.getFlashcardSetById(set['id']);
      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FlashcardStudyScreen(
                setId: fullSet['id'],
                title: fullSet['title'],
                cards: List<Map<String, dynamic>>.from(fullSet['cards'] ?? []),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Failed to load flashcards', isError: true);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF171717) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF664C9A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadFlashcardSets(forceRefresh: true),
          child:
              CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: _buildAppBar(
                          isDark,
                          surfaceColor,
                          textMain,
                          textSub,
                        ),
                      ),

                      // Hero Section
                      SliverToBoxAdapter(
                        child: _buildHeroSection(textMain, textSub, isDark),
                      ),

                      // Create Section (Input)
                      SliverToBoxAdapter(
                        child: _buildCreateSection(
                          isDark,
                          surfaceColor,
                          textMain,
                          textSub,
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildGenerateButton()),

                      // Stats Cards
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildStatsCards(
                            isDark,
                            surfaceColor,
                            textMain,
                            textSub,
                          ),
                        ),
                      ),

                      // Collection Header with Custom Tabs
                      SliverToBoxAdapter(
                        child: _buildTabBar(isDark, surfaceColor, textSub),
                      ),

                      // The List (conditionally filtered)
                      _buildFlashcardsList(
                        isDark,
                        surfaceColor,
                        textMain,
                        textSub,
                      ),

                      // Bottom Padding
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 100),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark, Color surfaceColor, Color textSub) {
    final tabs = ['Recommended', 'My Library', 'Recent'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : Colors.white,
        borderRadius: BorderRadius.circular(9999), // Full rounded
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedTab = entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : textSub,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlashcardsList(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: ShimmerPlaceholders.historyList(itemCount: 3),
        ),
      );
    }

    // Filter Logic
    // Filter Logic
    List<Map<String, dynamic>> filteredSets = [];
    final selectedExam = ref.watch(examProvider);

    if (_selectedTab == 0) {
      // Recommended / Exam Specific
      if (selectedExam == null) {
        // Show prompts to select exam
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExamSelectionScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Select Your Goal',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Choose an exam to get tailored flashcards.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // Return categorized content
        final sections = _getExamData(selectedExam);
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final subject = sections.keys.elementAt(index);
            final sets = sections[subject]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        subject,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                    ],
                  ),
                ),
                ...sets.map(
                  (set) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildFlashcardSetCard(
                      set,
                      isDark,
                      surfaceColor,
                      textMain,
                      textSub,
                    ),
                  ),
                ),
              ],
            );
          }, childCount: sections.length),
        );
      }
    } else {
      filteredSets = List.from(_flashcardSets);
      if (_selectedTab == 2) {
        // Recent (Tab index 2 in new list: Rec, MyLib, Fav? No. Tabs: Rec, My, Fav?)
        // Tabs: ['Recommended', 'My Library', 'Recent'] -> Indices: 0, 1, 2.
        // Wait, 'Recent' is index 2.
        filteredSets = filteredSets.take(5).toList();
      } else if (_selectedTab == 1) {
        // My Library (All user sets)
        // No filter needed.
      }
    }

    if (filteredSets.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(textMain, textSub),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildFlashcardSetCard(
                filteredSets[index],
                isDark,
                surfaceColor,
                textMain,
                textSub,
              )
              .animate(delay: (400 + (index * 80)).ms)
              .fade(duration: 400.ms)
              .slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
        }, childCount: filteredSets.length),
      ),
    );
  }

  Widget _buildFlashcardSetCard(
    Map<String, dynamic> set,
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final title = set['title'] ?? 'Untitled Set';
    final cardCount = set['cardCount'] ?? set['cards']?.length ?? 0;
    final isFavorite = set['isFavorite'] == true;

    return GestureDetector(
      onTap: () => _openFlashcardSet(set),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Wave background pattern (subtle)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.style,
                  size: 100,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.layers_rounded,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$cardCount Cards',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Favorite Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            // Logic to toggle favorite would go here
                            _showSnackBar('Added to favorites', isError: false);
                          },
                          child: Icon(
                            isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isFavorite
                                ? Colors.orange
                                : textSub.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0, // Placeholder for progress (0%)
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Tap to study',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSub,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: textSub,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textMain, Color textSub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.style_rounded,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Flashcards',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Create your first set above to get started!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: textSub,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _photoUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _userName.isNotEmpty
                                    ? _userName[0].toUpperCase()
                                    : 'Q',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'Q',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.flashcardsTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.yourCollection,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color textMain, Color textSub, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    TextSpan(text: AppLocalizations.of(context)!.studySmarter1),
                    TextSpan(
                      text: AppLocalizations.of(context)!.studySmarter2,
                      style: TextStyle(
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 700.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.studySmarterSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.whatsTheTopic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topicController,
            focusNode: _focusNode,
            maxLines: 2,
            minLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: textMain,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? surfaceColor : Colors.white,
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
              hintText: "e.g., 'Photosynthesis' or paste your notes here...",
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: textSub.withOpacity(0.6),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child:
          GestureDetector(
                onTap: _isGenerating ? null : _generateFlashcards,
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
                          'Generate Flashcards',
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

  Widget _buildStatsCards(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textSub,
  ) {
    final totalSets = _flashcardSets.length;
    final totalCards = _flashcardSets.fold<int>(
      0,
      (sum, set) =>
          sum + ((set['cardCount'] ?? set['cards']?.length ?? 0) as int),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(opacity: value, child: child),
              ),
              child: Container(
                height: 96,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? primaryColor.withOpacity(0.15)
                      : primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withOpacity(isDark ? 0.3 : 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY SETS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textSub,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '$totalSets',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(opacity: value, child: child),
              ),
              child: Container(
                height: 96,
                padding: const EdgeInsets.all(16),
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
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL CARDS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textSub,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '$totalCards',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textMain,
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

  Map<String, List<Map<String, dynamic>>> _getExamData(String exam) {
    final subjects = _getSubjectsForExam(exam);
    final data = <String, List<Map<String, dynamic>>>{};

    for (final subject in subjects) {
      data[subject] = [
        {
          'id': '${exam}_${subject}_1',
          'title': '$subject - Key Concepts',
          'cardCount': 20 + Random().nextInt(30),
          'isPremium': true,
        },
        {
          'id': '${exam}_${subject}_2',
          'title': '$subject - Practice Set',
          'cardCount': 40 + Random().nextInt(20),
          'isPremium': true,
        },
        {
          'id': '${exam}_${subject}_3',
          'title': 'Advanced $subject',
          'cardCount': 50,
          'isPremium': true,
        },
      ];
    }
    return data;
  }

  List<String> _getSubjectsForExam(String exam) {
    switch (exam.toLowerCase()) {
      case 'jee':
        return ['Physics', 'Chemistry', 'Mathematics'];
      case 'neet':
        return ['Biology', 'Physics', 'Chemistry'];
      case 'mba':
      case 'cat':
      case 'gmat':
      case 'gre':
        return ['Quantitative', 'Verbal Ability', 'Logical Reasoning'];
      case '10th':
      case '12th':
        return ['Science', 'Mathematics', 'English', 'Social Studies'];
      case 'ielts':
        return ['Reading', 'Writing', 'Listening', 'Speaking'];
      default:
        return ['General Knowledge', 'Aptitude'];
    }
  }

  void _showPremiumDialog(String itemName) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Premium Content 💎',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Unlock "$itemName" and thousands of other expert-curated materials with Quirzy Pro.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Subscription feature coming soon! 🚀');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B13EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Get Premium',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
