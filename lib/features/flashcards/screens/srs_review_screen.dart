import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/srs_service.dart';

class SrsReviewScreen extends StatefulWidget {
  final String setId;
  final String title;
  final List<Map<String, dynamic>> cards;
  final List<int> dueIndices;

  const SrsReviewScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.cards,
    required this.dueIndices,
  });

  @override
  State<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends State<SrsReviewScreen>
    with TickerProviderStateMixin {
  final SrsService _srs = SrsService();

  late List<int> _queue;
  int _queuePos = 0;
  bool _isFlipped = false;
  bool _showingAnswer = false;
  SrsCard? _lastRated;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  static const _purple = Color(0xFF5B13EC);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _queue = List.from(widget.dueIndices)..shuffle(Random());

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutBack),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  int get _currentCardIndex => _queue[_queuePos];
  Map<String, dynamic> get _currentCard => widget.cards[_currentCardIndex];

  String get _front =>
      _currentCard['front'] ?? _currentCard['question'] ?? '';
  String get _back =>
      _currentCard['back'] ?? _currentCard['answer'] ?? '';

  void _flip() {
    HapticFeedback.selectionClick();
    if (!_isFlipped) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
    setState(() {
      _isFlipped = !_isFlipped;
      _showingAnswer = _isFlipped;
    });
  }

  Future<void> _rate(SrsRating rating) async {
    HapticFeedback.lightImpact();
    final updated = await _srs.rateCard(widget.setId, _currentCardIndex, rating);
    setState(() => _lastRated = updated);

    if (rating == SrsRating.again) {
      // Re-insert near end of queue
      _queue.add(_currentCardIndex);
    }

    if (_queuePos >= _queue.length - 1) {
      _showSessionComplete();
      return;
    }

    setState(() {
      _queuePos++;
      _isFlipped = false;
      _showingAnswer = false;
    });
    _flipCtrl.reset();
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  void _showSessionComplete() {
    final done = widget.dueIndices.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A1A)
                : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_purple, Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                'Session Complete!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF120D1B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You reviewed $done card${done != 1 ? 's' : ''}. Come back tomorrow to keep your streak.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);

    final remaining = _queue.length - _queuePos;
    final progress = _queue.isEmpty ? 0.0 : _queuePos / _queue.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(color: Colors.white10)
                            : null,
                      ),
                      child: Icon(Icons.close_rounded, color: textMain, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SPACED REVIEW',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: _purple,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Due count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$remaining left',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: _purple.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(_purple),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SlideTransition(
                  position: _slideAnim,
                  child: GestureDetector(
                    onTap: _flip,
                    child: AnimatedBuilder(
                      animation: _flipAnim,
                      builder: (context, _) {
                        final angle = _flipAnim.value * pi;
                        final isFrontVisible = angle < pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: isFrontVisible
                              ? _buildFace(
                                  text: _front,
                                  label: 'CONCEPT',
                                  color: _purple,
                                  isDark: isDark,
                                  textMain: textMain,
                                  hint: 'Tap to reveal answer',
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildFace(
                                    text: _back,
                                    label: 'ANSWER',
                                    color: _green,
                                    isDark: isDark,
                                    textMain: textMain,
                                    hint: 'Rate your recall below',
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rating buttons (only shown after flip)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showingAnswer
                  ? _buildRatingRow(isDark, surfaceColor, textMain)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _flip,
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: Text(
                            'Show Answer',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: _purple.withOpacity(0.4)),
                            foregroundColor: _purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFace({
    required String text,
    required String label,
    required Color color,
    required bool isDark,
    required Color textMain,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.10), color.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.06),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textMain,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 14, color: color.withOpacity(0.5)),
                      const SizedBox(width: 6),
                      Text(
                        hint,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: color.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(bool isDark, Color surfaceColor, Color textMain) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'How well did you recall?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              _rateBtn(SrsRating.again, 'Again', _red, isDark, surfaceColor),
              const SizedBox(width: 8),
              _rateBtn(SrsRating.hard, 'Hard', _amber, isDark, surfaceColor),
              const SizedBox(width: 8),
              _rateBtn(SrsRating.good, 'Good', _blue, isDark, surfaceColor),
              const SizedBox(width: 8),
              _rateBtn(SrsRating.easy, 'Easy', _green, isDark, surfaceColor),
            ],
          ),
          if (_lastRated != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Next review: ${_lastRated!.nextReviewText}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rateBtn(
    SrsRating rating,
    String label,
    Color color,
    bool isDark,
    Color surface,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _rate(rating),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
