import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/screen/quizPage/quizCompletedScreen.dart';
import 'package:quirzy/utils/constant.dart';

class QuizQuestionScreen extends ConsumerStatefulWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> questions;

  const QuizQuestionScreen({
    super.key,
    required this.quizTitle,
    required this.questions,
  });

  @override
  ConsumerState<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends ConsumerState<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<bool> userAnswers;

  @override
  void initState() {
    super.initState();
    
    // Validate questions list
    if (widget.questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions available')),
        );
        Navigator.pop(context);
      });
      return;
    }

    userAnswers = List.filled(widget.questions.length, false);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  void handleNextQuestion() {
    if (selectedOption != null) {
      final currentQuestion = widget.questions[currentQuestionIndex];
      final isCorrect = selectedOption == 
          currentQuestion['options'][currentQuestion['correctAnswer']];
      
      if (isCorrect) {
        correctAnswers++;
        userAnswers[currentQuestionIndex] = true;
      }

      setState(() {
        selectedOption = null;
        if (currentQuestionIndex < widget.questions.length - 1) {
          currentQuestionIndex++;
          _resetAnimation();
        } else {
  
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                  QuizCompleteScreen(
                    quizTitle: widget.quizTitle,
                    score: correctAnswers,
                    totalQuestions: widget.questions.length,
                    userAnswers: userAnswers,
                    questions: widget.questions,
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an answer!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add another safety check
    if (widget.questions.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = widget.questions[currentQuestionIndex];
    final questionText = currentQuestion['questionText'];
    final options = (currentQuestion['options'] as List<dynamic>).cast<String>();
    final progressValue = (currentQuestionIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: kTextDark, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: kTextDark,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kBackgroundWhite,
        shadowColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: kTextLightGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    kSmallVerticalSpace,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: kOutlineGrey.withOpacity(0.5),
                        color: kPrimaryBlue,
                        minHeight: 6,
                      ),
                    ),
                    kLargeVerticalSpace,
                    Text(
                      questionText,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                        height: 1.3,
                      ),
                    ),
                    kLargeVerticalSpace,
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedOption == option;
                    
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: OptionCard(
                        key: ValueKey(option),
                        option: option,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              kLargeVerticalSpace,
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 30.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    key: ValueKey(currentQuestionIndex),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        minimumSize: const Size.fromHeight(60),
                      ),
                      onPressed: selectedOption != null ? handleNextQuestion : null,
                      child: Text(
                        currentQuestionIndex < widget.questions.length - 1 
                            ? "Next" 
                            : "Finish Quiz",
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryBlue.withOpacity(0.1) : kBackgroundWhite,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : kOutlineGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryBlue.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? kPrimaryBlue : kTextDark,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                key: ValueKey(isSelected),
                color: isSelected ? kPrimaryBlue : kTextLightGrey,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}