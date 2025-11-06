// lib/screen/quizPage/quiz_completed_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/utils/constant.dart';

class QuizCompleteScreen extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final List<bool> userAnswers;
  final List<Map<String, dynamic>> questions;

  const QuizCompleteScreen({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.userAnswers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.popUntil(context, (route) => route.isFirst);
        }, icon: Icon(Icons.home)),
        title: Text(
          "Quiz Results",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: kTextDark,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBackgroundWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            kExtraLargeVerticalSpace,
            Text(
              'Quiz Complete!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            kMediumVerticalSpace,
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryBlue.withOpacity(0.1),
                border: Border.all(
                  color: kPrimaryBlue,
                  width: 5,
                ),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ),
            ),
            kLargeVerticalSpace,
            Text(
              'You scored $score out of $totalQuestions',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kTextDark,
              ),
            ),
            kMediumVerticalSpace,
            Text(
              "Review your answers below:",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: kTextLightGrey,
                height: 1.4,
              ),
            ),
            kLargeVerticalSpace,
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final isCorrect = userAnswers[index];
                  final options = (question['options'] as List<dynamic>).cast<String>();
                  final correctAnswer = options[question['correctAnswer']];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question['questionText'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Correct answer: $correctAnswer',
                            style: GoogleFonts.poppins(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            kLargeVerticalSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  "Go Home",
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}