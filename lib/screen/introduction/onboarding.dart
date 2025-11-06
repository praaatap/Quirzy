import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:quirzy/screen/introduction/welcome.dart';
import 'package:quirzy/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final List<PageViewModel> _pages = [
    PageViewModel(
      title: "Welcome",
      body: "Challenge yourself with AI-generated quizzes.",
      image: Image.asset('assets/animation1.png', height: 200),

    ),
    PageViewModel(
      title: "Compete",
      body: "Track your progress with stats.",
      image: Image.asset('assets/animation2.png', height: 200),
    ),
    PageViewModel(
      title: "Challenge Friends",
      body: "Create quizzes and compete with friends!",
      image: Image.asset('assets/animation3.png', height: 200),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: _pages,
        onDone: ()async {
          final prefs = await SharedPreferences.getInstance(); 
          await prefs.setBool(kOnbordingStatus, true);
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuiryHome()),
        );
        },
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Icon(Icons.arrow_forward),
        done: const Text("Done"),
      ),
    );
  }
}
