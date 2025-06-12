import 'package:flutter/material.dart';
import 'package:quirzy/screen/mainScreen/historyScreen.dart';
import 'package:quirzy/screen/quizhome.dart';
import 'package:quirzy/screen/mainScreen/settings.dart';
import 'package:quirzy/widgets/customNavbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    QuizHomePage(),
    Historyscreen(),
    SettingPage(),
  ];

  void _onNavItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
