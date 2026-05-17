import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_test_service.dart';
import '../providers/quiz_providers.dart';
import 'mock_test_result_screen.dart';

class MockTestScreen extends ConsumerStatefulWidget {
  final MockTestData mockTest;

  const MockTestScreen({super.key, required this.mockTest});

  @override
  ConsumerState<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends ConsumerState<MockTestScreen> {
  late List<int?> _answers;
  late Set<int> _markedForReview;
  late int _remainingSeconds;
  late Timer _timer;
  int _currentSectionIndex = 0;
  int _currentQuestionInSection = 0;
  bool _isSubmitting = false;

  static const _primaryColor = Color(0xFF5B13EC);

  @override
  void initState() {
    super.initState();
    final total = widget.mockTest.totalQuestions;
    _answers = List.filled(total, null);
    _markedForReview = {};
    _remainingSeconds = widget.mockTest.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _submitTest();
        return;
      }
      if (mounted) setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int get _globalQuestionIndex {
    int base = 0;
    for (int i = 0; i < _currentSectionIndex; i++) {
      base += widget.mockTest.sections[i].questionCount;
    }
    return base + _currentQuestionInSection;
  }

  Map<String, dynamic> get _currentQuestion {
    return widget.mockTest.questions[_globalQuestionIndex];
  }

  void _selectOption(int optionIndex) {
    HapticFeedback.selectionClick();
    setState(() => _answers[_globalQuestionIndex] = optionIndex);
  }

  void _toggleMarkForReview() {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _globalQuestionIndex;
      if (_markedForReview.contains(idx)) {
        _markedForReview.remove(idx);
      } else {
        _markedForReview.add(idx);
      }
    });
  }

  void _navigateToQuestion(int sectionIdx, int questionIdx) {
    setState(() {
      _currentSectionIndex = sectionIdx;
      _currentQuestionInSection = questionIdx;
    });
    Navigator.pop(context); // close drawer
  }

  void _goNext() {
    final section = widget.mockTest.sections[_currentSectionIndex];
    if (_currentQuestionInSection < section.questionCount - 1) {
      setState(() => _currentQuestionInSection++);
    } else if (_currentSectionIndex < widget.mockTest.sections.length - 1) {
      setState(() {
        _currentSectionIndex++;
        _currentQuestionInSection = 0;
      });
    }
  }

  void _goPrev() {
    if (_currentQuestionInSection > 0) {
      setState(() => _currentQuestionInSection--);
    } else if (_currentSectionIndex > 0) {
      setState(() {
        _currentSectionIndex--;
        _currentQuestionInSection = widget.mockTest.sections[_currentSectionIndex].questionCount - 1;
      });
    }
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) return;
    _timer.cancel();

    final answered = _answers.where((a) => a != null).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Submit Test?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text(
          'You have answered $answered out of ${widget.mockTest.totalQuestions} questions.\n\nAre you sure you want to submit?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: Text('Submit', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true && _remainingSeconds > 0) {
      _startTimer();
      return;
    }

    setState(() => _isSubmitting = true);

    // Calculate scores per section
    int totalScore = 0;
    final sections = widget.mockTest.sections;

    for (int si = 0; si < sections.length; si++) {
      int base = 0;
      for (int i = 0; i < si; i++) base += sections[i].questionCount;

      int sectionCorrect = 0;
      int sectionAttempted = 0;

      for (int qi = 0; qi < sections[si].questionCount; qi++) {
        final globalIdx = base + qi;
        final answer = _answers[globalIdx];
        if (answer != null) {
          sectionAttempted++;
          final correctAnswer = widget.mockTest.questions[globalIdx]['correctAnswer'] as int;
          if (answer == correctAnswer) {
            sectionCorrect++;
            totalScore++;
          }
        }
      }

      sections[si].correct = sectionCorrect;
      sections[si].attempted = sectionAttempted;
    }

    final timeTaken = widget.mockTest.durationMinutes * 60 - _remainingSeconds;

    // Save result
    try {
      final service = ref.read(mockTestServiceProvider);
      await service.saveMockTestResult(
        mockTestId: widget.mockTest.mockTestId,
        score: totalScore,
        totalQuestions: widget.mockTest.totalQuestions,
        timeTakenSeconds: timeTaken,
        sections: sections,
      );
    } catch (_) {}

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MockTestResultScreen(
            mockTest: widget.mockTest,
            answers: List.from(_answers),
            score: totalScore,
            timeTakenSeconds: timeTaken,
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 300) return Colors.red;
    if (_remainingSeconds <= 900) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);

    final section = widget.mockTest.sections[_currentSectionIndex];
    final question = _currentQuestion;
    final globalIdx = _globalQuestionIndex;
    final selectedAnswer = _answers[globalIdx];
    final isMarked = _markedForReview.contains(globalIdx);

    return WillPopScope(
      onWillPop: () async {
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Leave Test?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            content: Text('Your progress will be lost.', style: GoogleFonts.plusJakartaSans()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        return leave == true;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textMain, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getTimerColor().withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 16, color: _getTimerColor()),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getTimerColor(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _submitTest,
                style: TextButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Submit', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          bottom: widget.mockTest.sections.length > 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: widget.mockTest.sections.asMap().entries.map((entry) {
                        final isActive = entry.key == _currentSectionIndex;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _currentSectionIndex = entry.key;
                            _currentQuestionInSection = 0;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? _primaryColor : (isDark ? Colors.white10 : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              entry.value.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : textMain,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              : null,
        ),
        endDrawer: _buildQuestionGridDrawer(isDark, surfaceColor, textMain),
        body: Column(
          children: [
            // Question counter + mark for review
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q ${_currentQuestionInSection + 1} / ${section.questionCount}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textMain),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleMarkForReview,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isMarked ? Colors.amber.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isMarked ? Colors.amber : Colors.grey.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_rounded, size: 14, color: isMarked ? Colors.amber : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                isMarked ? 'Marked' : 'Mark',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isMarked ? Colors.amber : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Builder(builder: (ctx) => IconButton(
                        icon: const Icon(Icons.grid_view_rounded),
                        iconSize: 20,
                        color: textMain,
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      )),
                    ],
                  ),
                ],
              ),
            ),

            // Question + Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Text(
                        question['questionText'] as String? ?? '',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: textMain, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...(question['options'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
                      final optIdx = entry.key;
                      final optText = entry.value as String;
                      final isSelected = selectedAnswer == optIdx;

                      return GestureDetector(
                        onTap: () => _selectOption(optIdx),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryColor.withOpacity(0.12) : surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? _primaryColor : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryColor : (isDark ? Colors.white10 : Colors.grey[100]),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  String.fromCharCode(65 + optIdx),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : textMain,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: textMain,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Prev / Next navigation
            Container(
              color: surfaceColor,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goPrev,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('← Prev', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textMain)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Next →', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGridDrawer(bool isDark, Color surfaceColor, Color textMain) {
    return Drawer(
      backgroundColor: surfaceColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Question Palette', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textMain)),
            ),
            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _legendItem(Colors.green, 'Answered'),
                  _legendItem(Colors.amber, 'Marked'),
                  _legendItem(isDark ? Colors.white24 : Colors.grey.shade200, 'Not Answered'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: widget.mockTest.sections.asMap().entries.map((sEntry) {
                  final si = sEntry.key;
                  final section = sEntry.value;
                  int base = 0;
                  for (int i = 0; i < si; i++) base += widget.mockTest.sections[i].questionCount;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(section.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: textMain)),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 5,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        children: List.generate(section.questionCount, (qi) {
                          final gIdx = base + qi;
                          final isAnswered = _answers[gIdx] != null;
                          final isMarkedQ = _markedForReview.contains(gIdx);
                          final isCurrentQ = si == _currentSectionIndex && qi == _currentQuestionInSection;

                          return GestureDetector(
                            onTap: () => _navigateToQuestion(si, qi),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrentQ
                                    ? const Color(0xFF5B13EC)
                                    : isMarkedQ
                                        ? Colors.amber
                                        : isAnswered
                                            ? Colors.green
                                            : (isDark ? Colors.white10 : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${qi + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: (isCurrentQ || isMarkedQ || isAnswered) ? Colors.white : textMain,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
