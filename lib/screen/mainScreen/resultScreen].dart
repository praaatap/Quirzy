import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/quizquestion.dart';

class QuizResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionData;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questionData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Results", style: GoogleFonts.poppins(fontSize: 20)),
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
            // 🎉 Title
            Text(
              "Quiz Completed!",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // 📊 Score and Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "$score/$totalQuestions",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: score / totalQuestions,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            const SizedBox(height: 24),

            // 🟢 Correct and Incorrect Answers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResultBox(
                  label: "Correct Answers",
                  count: score,
                ),
                _buildResultBox(
                  label: "Incorrect Answers",
                  count: totalQuestions - score,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ❓ Review Questions
            Text(
              "Review Questions",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // List of Questions
            Expanded(
              child: ListView.builder(
                itemCount: questionData.length,
                itemBuilder: (context, index) {
                  final question = questionData[index]['question'];
                  final answer = questionData[index]['userAnswer'];

                  return ListTile(
                    title: Text(
                      "Question ${index + 1}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "Your answer: $answer",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 🔄 Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic to retake the quiz
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => QuizQuestionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Retake Quiz",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Logic to go back to home screen
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Back to Home",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for result boxes
  Widget _buildResultBox({required String label, required int count}) {
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
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}