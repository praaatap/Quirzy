import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/screen/quizhome.dart';
import 'package:quirzy/screen/introduction/signIn.dart';
import 'package:quirzy/screen/introduction/signup.dart';
import 'package:quirzy/screen/introduction/welcome.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const QuiryHome(),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const QuizHomePage(),
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        primary: Colors.blueGrey.shade700,
        secondary: Colors.blueGrey.shade500,
        surface: Colors.white,
        onSurface: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.black),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueGrey.shade700,
        unselectedItemColor: Colors.blueGrey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.blueGrey.shade700),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blueGrey.shade300;
          }
          return Colors.grey.shade300;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
    );
  }
}