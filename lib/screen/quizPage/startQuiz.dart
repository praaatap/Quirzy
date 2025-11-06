// lib/screen/quizPage/start_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/quizPage/quizQuestion.dart';
import 'package:quirzy/utils/constant.dart';

class StartQuizScreen extends StatelessWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> questions;
  
  const StartQuizScreen({
    super.key,
    required this.quizTitle,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Quiz Ready",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: kTextDark,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBackgroundWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'AI Quiz: $quizTitle',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: kTextDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your quiz is ready! Test your knowledge on this topic.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size.fromHeight(55),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionScreen(
                        quizTitle: quizTitle,
                        questions: questions,
                      ),
                    ),
                  );
                },
                child: Text(
                  "Start Quiz",
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}