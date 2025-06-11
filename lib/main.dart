import 'package:flutter/material.dart';
import 'package:quirzy/screen/Home.dart';
import 'package:quirzy/screen/signIn.dart';
import 'package:quirzy/screen/signup.dart';
import 'package:quirzy/screen/welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: QuiryHome(),
      routes: {
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home':(context) => QuizHomePage()
      },
    );
  }
}

