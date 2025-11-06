import 'package:flutter/material.dart';
import 'package:quirzy/screen/introduction/signIn.dart';
import 'package:quirzy/screen/introduction/signup.dart';
import 'package:quirzy/widgets/Button.dart';

class QuiryHome extends StatelessWidget {
  const QuiryHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.35, // Responsive height
                  width: double.infinity,
                  child: Image.asset('assets/welcome.png', fit: BoxFit.cover),
                ),
                SizedBox(height: size.height * 0.03),

                // Heading
                Text(
                  "Welcome to Quirzy",
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: size.width * 0.08, // Responsive font size
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.02),

                // Subtitle
                Text(
                  "Challenge yourself with AI-generated quizzes, track your progress, and compete with friends.\nSign in or sign up to get started!",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: size.width * 0.04, // Responsive font size
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // Buttons placed right after text
                SizedBox(
                  width: double.infinity,
                  child: ReusableButton(
                    label: 'Sign in',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                SizedBox(
                  width: double.infinity,
                  child: ReusableButton(
                    label: "Sign Up",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                  ),
                ),

                // Add additional space at bottom if needed
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
