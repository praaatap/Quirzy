import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/service/quiz_service.dart';
import 'package:quirzy/service/ad_service.dart';
import 'package:quirzy/screen/quizPage/startQuiz.dart';

// ==========================================
// HOME SCREEN
// ==========================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _quizIdeaController = TextEditingController();
  
  bool _isGenerating = false;
  int _remainingFree = 0;

  @override
  void initState() {
    super.initState();
    _loadAdInfo();
  }

  Future<void> _loadAdInfo() async {
    await AdService().initialize();
    _refreshRemainingCount();
  }

  void _refreshRemainingCount() {
    if (!mounted) return;
    setState(() {
      _remainingFree = AdService().getRemainingFreeQuizzes();
    });
  }

  @override
  void dispose() {
    _quizIdeaController.dispose();
    super.dispose();
  }

  Future<void> _handleGeneratePress() async {
    FocusScope.of(context).unfocus(); 
    HapticFeedback.selectionClick();

    if (_quizIdeaController.text.trim().isEmpty) {
      _showSnackBar('Please enter a topic first', isError: true);
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
      onAdFailed: () => _showSnackBar('Ad failed to load. Check connection.', isError: true),
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
        MaterialPageRoute(
          builder: (_) => StartQuizScreen(
            quizId: result['quizId'].toString(),
            quizTitle: result['title'] ?? _quizIdeaController.text.trim(),
            questions: questions,
            difficulty: null,
          ),
        ),
      );

      _quizIdeaController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showErrorDialog('Error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ooops', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAdConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.movie_filter_rounded, size: 40, color: Colors.amber),
        title: Text('Free Limit Reached', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Watch a short ad to generate this quiz?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _playAdAndGenerate();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Watch Ad', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Static Background
          const _BackgroundDecoration(),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Quirzy',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                actions: [
                  _QuotaBadge(remainingFree: _remainingFree),
                  const SizedBox(width: 16),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    const _SectionHeader(),
                    const SizedBox(height: 30),

                    // Smart Input Area (Handles Clipboard internally)
                    _SmartQuizInputArea(
                      controller: _quizIdeaController,
                      isGenerating: _isGenerating,
                    ),
                    
                    const SizedBox(height: 30),

                    _GenerateButton(
                      isGenerating: _isGenerating,
                      isLimitReached: AdService().isLimitReached(),
                      onPressed: _handleGeneratePress,
                    ),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// OPTIMIZED WIDGETS
// ==========================================

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.05 : 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withOpacity(isDark ? 0.04 : 0.06),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  final int remainingFree;
  const _QuotaBadge({required this.remainingFree});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCredits = remainingFree > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasCredits ? theme.colorScheme.primaryContainer : Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCredits ? theme.colorScheme.primary : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasCredits ? Icons.bolt_rounded : Icons.lock_clock,
            size: 14,
            color: hasCredits ? theme.colorScheme.primary : Colors.amber[800],
          ),
          const SizedBox(width: 6),
          Text(
            hasCredits ? '$remainingFree left' : 'Ads',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasCredits ? theme.colorScheme.onPrimaryContainer : Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to learn?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste notes, enter a topic, or type a subject.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SmartQuizInputArea extends StatefulWidget {
  final TextEditingController controller;
  final bool isGenerating;

  const _SmartQuizInputArea({required this.controller, required this.isGenerating});

  @override
  State<_SmartQuizInputArea> createState() => _SmartQuizInputAreaState();
}

class _SmartQuizInputAreaState extends State<_SmartQuizInputArea> with WidgetsBindingObserver {
  bool _showPasteButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkClipboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check clipboard when user returns to the app
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final hasContent = await Clipboard.hasStrings();
    if (mounted && _showPasteButton != hasContent) {
      setState(() => _showPasteButton = hasContent);
    }
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.mediumImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      widget.controller.text = data!.text!;
      // Hide paste button logic (optional, keeping it true allows consecutive pastes)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            enabled: !widget.isGenerating,
            keyboardType: TextInputType.multiline,
            minLines: 6,
            maxLines: 10,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: "Type a topic (e.g., 'French Revolution') or paste your study notes here...",
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
          
          // Action Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Clear Button
                SizedBox(
                  height: 10,
                ),
                IconButton(
                  onPressed: () {
                    widget.controller.clear();
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(Icons.clear, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  tooltip: 'Clear',
                ),

                // Conditional Paste Button
                if (_showPasteButton)
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      label: Text("Paste from Clipboard", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
    
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isGenerating ? 0 : 5,
          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
        ),
        onPressed: isGenerating ? null : onPressed,
        child: isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5, 
                      color: theme.colorScheme.onPrimary.withOpacity(0.8)
                    )
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Creating Magic...",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isLimitReached ? Icons.play_circle_filled_rounded : Icons.auto_awesome_rounded),
                  const SizedBox(width: 12),
                  Text(
                    isLimitReached ? "Watch Ad & Generate" : "Generate Quiz",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
      ),
    );
  }
}