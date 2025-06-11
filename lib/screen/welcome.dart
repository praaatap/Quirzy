import 'package:flutter/material.dart';
import 'package:quirzy/widgets/Button.dart';

class QuiryHome extends StatelessWidget {
  const QuiryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Illustration
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Image.asset('assets/welcome.png', fit: BoxFit.cover),
            ),

            const SizedBox(height: 24),

            // Heading
            const Text(
              "Welcome to QuizMaster",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 26,
                fontFamily: 'Roboto',
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Challenge yourself with AI-generated quizzes, track your progress, and compete with friends.\nSign in or sign up to get started!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 32),

            ReusableButton(
              backgroundColor: Colors.blue.shade500,
              label: 'Sign in',
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
            ),

            const SizedBox(height: 16),

            ReusableButton(
              label: "Sign Up",
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              backgroundColor: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
