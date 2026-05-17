import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_providers.dart';
import '../../../shared/widgets/pro_gate.dart';
import 'mock_test_screen.dart';
import 'quiz_generation_loading_screen.dart';

class MockTestSetupScreen extends ConsumerWidget {
  const MockTestSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProGate(
      featureName: 'Mock Tests',
      description: 'Take full-length timed mock exams for JEE, NEET, CAT and more with section-wise analysis.',
      icon: Icons.assignment_turned_in_rounded,
      child: _MockTestSetupContent(),
    );
  }
}

class _MockTestSetupContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MockTestSetupContent> createState() => _MockTestSetupContentState();
}

class _MockTestSetupContentState extends ConsumerState<_MockTestSetupContent> {
  String _selectedExam = 'JEE';
  bool _isGenerating = false;

  static const _primaryColor = Color(0xFF5B13EC);

  final Map<String, Map<String, dynamic>> _examInfo = {
    'JEE': {'icon': '⚛️', 'label': 'JEE Main/Advanced', 'desc': '90 Qs • 3 hrs', 'color': Color(0xFF3B82F6)},
    'NEET': {'icon': '🧬', 'label': 'NEET UG', 'desc': '180 Qs • 3h 20m', 'color': Color(0xFF10B981)},
    'CAT': {'icon': '📊', 'label': 'CAT MBA', 'desc': '66 Qs • 2 hrs', 'color': Color(0xFFF59E0B)},
    'CUET': {'icon': '🎓', 'label': 'CUET UG', 'desc': '100 Qs • 2 hrs', 'color': Color(0xFF8B5CF6)},
    'MBA': {'icon': '💼', 'label': 'MBA Entrance', 'desc': '95 Qs • 1h 45m', 'color': Color(0xFFEC4899)},
    'GRE': {'icon': '🌍', 'label': 'GRE', 'desc': '80 Qs • 3h 50m', 'color': Color(0xFF6366F1)},
    'IELTS': {'icon': '🗣️', 'label': 'IELTS', 'desc': '40 Qs • 1 hr', 'color': Color(0xFF06B6D4)},
    'GMAT': {'icon': '📈', 'label': 'GMAT', 'desc': '67 Qs • 3h 7m', 'color': Color(0xFFEF4444)},
    'General': {'icon': '🌐', 'label': 'General Knowledge', 'desc': '50 Qs • 1 hr', 'color': Color(0xFF64748B)},
  };

  Future<void> _startMockTest() async {
    HapticFeedback.lightImpact();
    setState(() => _isGenerating = true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizGenerationLoadingScreen()),
    );

    try {
      final service = ref.read(mockTestServiceProvider);
      final mockTest = await service.generateMockTest(examType: _selectedExam);

      if (mounted) {
        Navigator.pop(context); // dismiss loading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MockTestScreen(mockTest: mockTest)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate mock test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F8FC);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF120D1B);
    final textSub = isDark ? Colors.white60 : const Color(0xFF64748B);

    final historyAsync = ref.watch(mockTestHistoryProvider);
    final selectedInfo = _examInfo[_selectedExam]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Mock Tests', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: textMain)),
        iconTheme: IconThemeData(color: textMain),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Selected exam preview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (selectedInfo['color'] as Color).withOpacity(0.15),
                          _primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (selectedInfo['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(selectedInfo['icon'] as String, style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedInfo['label'] as String,
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedInfo['desc'] as String,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textSub),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Selected', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Exam selector grid
                  Text('Choose Exam', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: _examInfo.entries.map((entry) {
                      final isSelected = _selectedExam == entry.key;
                      final info = entry.value;
                      final color = info['color'] as Color;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedExam = entry.key);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.15) : surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(info['icon'] as String, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 6),
                              Text(
                                entry.key,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? color : textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Recent mock tests
                  Text('Recent Tests', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                  const SizedBox(height: 12),
                  historyAsync.when(
                    data: (history) {
                      if (history.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Center(
                            child: Text('No mock tests yet. Take your first one!',
                              style: GoogleFonts.plusJakartaSans(color: textSub)),
                          ),
                        );
                      }
                      return Column(
                        children: history.take(3).map((test) {
                          final pct = (test['percentage'] as num?)?.toDouble() ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: pct >= 80 ? Colors.green.withOpacity(0.15) : pct >= 60 ? Colors.orange.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: pct >= 80 ? Colors.green : pct >= 60 ? Colors.orange : Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(test['title'] as String? ?? 'Mock Test',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textMain, fontSize: 13)),
                                      Text('${test['examType']} • ${test['score']}/${test['totalQuestions']}',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _startMockTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Start ${_selectedExam} Mock Test',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
