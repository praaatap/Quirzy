import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../shared/providers/exam_provider.dart';

class ExamSelectionScreen extends ConsumerStatefulWidget {
  const ExamSelectionScreen({super.key});

  @override
  ConsumerState<ExamSelectionScreen> createState() =>
      _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends ConsumerState<ExamSelectionScreen> {
  String? _selectedExam;

  final List<Map<String, dynamic>> _exams = [
    {'id': 'mba', 'name': 'MBA', 'icon': '💼', 'color': Color(0xFF5B13EC)},
    {'id': 'cat', 'name': 'CAT', 'icon': '📊', 'color': Color(0xFFFF6B6B)},
    {'id': 'cuet', 'name': 'CUET', 'icon': '🎓', 'color': Color(0xFF4ECDC4)},
    {'id': 'jee', 'name': 'JEE', 'icon': '⚙️', 'color': Color(0xFF45B7D1)},
    {'id': 'neet', 'name': 'NEET', 'icon': '⚕️', 'color': Color(0xFF96CEB4)},
    {
      'id': '10th',
      'name': '10th Board',
      'icon': '🔟',
      'color': Color(0xFFFFBE0B),
    },
    {
      'id': '12th',
      'name': '12th Board',
      'icon': '🏫',
      'color': Color(0xFFFF006E),
    },
    {'id': 'ielts', 'name': 'IELTS', 'icon': '🌏', 'color': Color(0xFF3A86FF)},
    {'id': 'gre', 'name': 'GRE', 'icon': '📈', 'color': Color(0xFF8338EC)},
    {'id': 'gmat', 'name': 'GMAT', 'icon': '📉', 'color': Color(0xFFFB5607)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Prepare for Success 🎯',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Which exam are you targeting?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final isSelected = _selectedExam == exam['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExam = exam['id'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (exam['color'] as Color).withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (exam['color'] as Color)
                                : const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (exam['color'] as Color).withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              exam['icon'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exam['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Icon(
                                Icons.check_circle_rounded,
                                color: exam['color'],
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedExam != null
                    ? () {
                        ref.read(examProvider.notifier).setExam(_selectedExam!);
                        Navigator.of(
                          context,
                        ).pop(); // Go back to Main/Home assuming it was pushed
                        // OR if it's the root, we might need to navigate differently.
                        // For now, let's assume MainScreen will redirect here if needed, and popping returns.
                        // IF we are replacing MainScreen, we should use go_router or pushReplacement.
                        // I'll stick to pop if pushed. If checking in MainScreen, MainScreen stays in stack?
                        // Actually, if prompted from MainScreen, popping works.
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B13EC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                ),
                child: Text(
                  'Start Preparing',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
