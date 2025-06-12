import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/quizquestion.dart';
import 'package:quirzy/widgets/Button.dart';

class Quizscreen extends StatelessWidget {
  const Quizscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Quiz Ready",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📝 Main Heading
            Text(
              "AI Quiz: History of Ancient Egypt",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // 📝 Subheading
            Text(
              "Your quiz is ready! Test your knowledge on the fascinating history of Ancient Egypt.",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            ReusableButton(label: 'Start Quiz', onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> QuizQuestionScreen()));
            }),
          ],
        ),
      ),
    );
  }
}
