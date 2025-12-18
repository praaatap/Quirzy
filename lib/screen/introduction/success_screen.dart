import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/mainPage/mainScreen.dart';

class SuccessScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final String message;
  final String? subtitle;

  const SuccessScreen({
    super.key,
    required this.onComplete,
    this.message = 'Account Created!',
    this.subtitle = 'Welcome to Quirzy',
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for circle
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Check mark animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // Fade animation for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start animations sequence
    _startAnimations();

    Future.delayed(Duration(seconds: 4),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(),));
    });
  }



  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    // Navigate after animations complete
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ScaleTransition(
                    scale: _checkAnimation,
                    child: Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: size.height * 0.01),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
