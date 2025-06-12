import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/mainScreen/resultScreen%5D.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  late Map<String, dynamic> currentQuiz;
  String? selectedAnswer;

  final List<Map<String, dynamic>> quizData = [
    {
      'question': 'What is the capital of France?',
      'options': ['Paris', 'London', 'Berlin', 'Rome'],
      'correctAnswer': 'Paris',
    },
    {
      'question': 'Who wrote "Hamlet"?',
      'options': ['William Shakespeare', 'Charles Dickens', 'Leo Tolstoy', 'Ernest Hemingway'],
      'correctAnswer': 'William Shakespeare',
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Earth', 'Mars', 'Jupiter', 'Venus'],
      'correctAnswer': 'Mars',
    },
    {
      'question': 'How many continents are there on Earth?',
      'options': ['5', '6', '7', '8'],
      'correctAnswer': '7',
    },
    {
      'question': 'In which year did the Titanic sink?',
      'options': ['1905', '1912', '1921', '1930'],
      'correctAnswer': '1912',
    },
  ];

  void _nextQuestion() {
    if (selectedAnswer != null) {
      // Check if answer is correct
      if (selectedAnswer == currentQuiz['correctAnswer']) {
        score++;
      }

      setState(() {
        if (currentQuestionIndex < quizData.length - 1) {
          currentQuestionIndex++;
          currentQuiz = quizData[currentQuestionIndex];
          selectedAnswer = null;
        } else {
          _navigateToResults(context);
        }
      });
    }
  }

  void _navigateToResults(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          score: score,
          totalQuestions: quizData.length,
          questionData: quizData.map((q) => {
            'question': q['question'],
            'userAnswer': selectedAnswer ?? 'Not answered',
          }).toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentQuiz = quizData[currentQuestionIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Quiz", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Question Progress Bar
            Row(
              children: [
                Text(
                  "Question ${currentQuestionIndex + 1}/${quizData.length}",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / quizData.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ⏱ Timer Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeBox("00", "Minutes"),
                _buildTimeBox("55", "Seconds"),
              ],
            ),

            const SizedBox(height: 30),

            // ❓ Question Text
            Text(
              currentQuiz['question'],
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // 🟢 Answer Options
            ...currentQuiz['options'].map<Widget>((option) {
              final isSelected = selectedAnswer == option;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: RadioListTile<String>(
                  title: Text(option, style: GoogleFonts.poppins(fontSize: 18)),
                  value: option,
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  activeColor: Colors.blue,
                  tileColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // ➡️ Next Button
            ElevatedButton(
              onPressed: selectedAnswer != null ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedAnswer != null ? Colors.blue : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                "Next",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for timer boxes
  Widget _buildTimeBox(String time, String label) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}