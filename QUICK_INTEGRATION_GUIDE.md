# 🎯 QUICK INTEGRATION GUIDE

This file shows exactly how to integrate micro-animations into your existing `quiz_question_screen.dart` file.

Copy and paste these code snippets into your `lib/features/quiz/screens/quiz_question_screen.dart`.

## 1. Add Imports
Add these at the top of the file:

```dart
import 'package:quirzy/core/widgets/micro_animations.dart';
import 'package:quirzy/core/widgets/quiz_timer_widget.dart';
import 'package:quirzy/core/widgets/level_up_animation.dart';
```

## 2. Replace Timer Display
In the `AppBar` `title`, locate the existing container with the timer row.

**Replace:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  // ... existing decoration ...
  child: Row(
    children: [
      Icon(_isFrozen ? Icons.ac_unit : Icons.timer_rounded, ...),
      // ...
    ],
  ),
)
```

**With:**
```dart
CompactTimerIndicator(
  secondsRemaining: _secondsRemaining,
  totalSeconds: widget.timePerQuestion,
  isPaused: _isFrozen,
)
```

## 3. Add Animated Buttons
Where you have the "Next Question" / "Finish Quiz" `ElevatedButton`.

**Wrap the button with `AnimatedTapButton`:**

```dart
AnimatedTapButton(
  onTap: selectedOption != null && !_isAnswerSubmitted
      ? () => _handleNextQuestion()
      : null,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      // ... keep your existing style
    ),
    onPressed: selectedOption != null && !_isAnswerSubmitted
        ? () => _handleNextQuestion()
        : null,
    child: Text(
      currentQuestionIndex < widget.questions.length - 1
          ? 'Next Question'
          : 'Finish Quiz',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

## 4. Add Success Ripple & XP Popup
In your `_handleNextQuestion` method, update the logic when an answer is selected.

**Update the `if (isCorrect)` block:**

```dart
    if (selectedOption != null) {
      final selectedIndex = options.indexOf(selectedOption!);
      userSelectedAnswers[currentQuestionIndex] = selectedIndex;
      isCorrect = selectedIndex == currentQuestion['correctAnswer'];

      // ✨ NEW: Add this block
      if (isCorrect) {
        HapticFeedback.mediumImpact(); // Extra feedback
        _showXPGainPopup(context, 10, 'Correct!'); // Show popup
      }
      // ✨ END NEW

      if (isCorrect && !userAnswers[currentQuestionIndex]) {
        correctAnswers++;
        userAnswers[currentQuestionIndex] = true;
      }
    }
```

## 5. Add Helper Method
Add this method to your `_QuizQuestionScreenState` class:

```dart
  void _showXPGainPopup(BuildContext context, int amount, String reason) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 0,
        right: 0,
        child: Center(
          child: XPGainPopup(
            xpAmount: amount,
            reason: reason,
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto remove after animation
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
```

## 6. Animate Option Cards
In the `OptionCard` `build` method (at the bottom of the file).

**Replace `GestureDetector` with `AnimatedTapButton`:**

```dart
  @override
  Widget build(BuildContext context) {
    // ... existing color logic ...

    return AnimatedTapButton( // Changed from GestureDetector
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        // ... rest of your existing container code
      ),
    );
  }
```

## 7. Animate Power-Up Buttons
In `_buildPowerUpButton`:

**Wrap the existing `AnimatedContainer` (or whatever widget is returned) with:**

```dart
    return AnimatedTapButton(
      onTap: isUsed ? null : onTap,
      child: AnimatedContainer(
        // ... your existing code ...
      ),
    );
```

---

## 🚀 Summary
1. **Timer**: Swapped static text for `CompactTimerIndicator`.
2. **Buttons**: Wrapped main button, options, and power-ups with `AnimatedTapButton`.
3. **Feedback**: Added `XPGainPopup` and haptic feedback on correct answers.
