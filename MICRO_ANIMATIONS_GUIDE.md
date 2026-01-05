# 🎮 Micro-Animations Guide for Quirzy

This document shows you how to use all the micro-animations in your quiz app.

## 📦 Installed Libraries

- `flutter_animate` - General purpose animations
- `confetti` - Confetti effects for celebrations
- `percent_indicator` - Animated progress indicators
- `circular_countdown_timer` - Circular countdown timers

## 🎯 Available Animations

### 1. Timer Animations ⏱️

**Circular Countdown Timer with Color Changes** (Green → Yellow → Red)

```dart
import 'package:quirzy/core/widgets/quiz_timer_widget.dart';

// Method 1: Using library (recommended)
QuizCountdownTimer(
  duration: 30,
  controller: myController,
  onComplete: () {
    print('Time up!');
  },
  isActive: true,
)

// Method 2: Custom animated timer
AnimatedCircularTimer(
  seconds: 30,
  onComplete: () {
    print('Time up!');
  },
  isPaused: false,
)

// Method 3: Compact indicator for AppBar
CompactTimerIndicator(
  secondsRemaining: 15,
  totalSeconds: 30,
  isPaused: false,
)
```

### 2. Button Animations 🎯

**Shrink on Tap + Bounce on Success**

```dart
import 'package:quirzy/core/widgets/micro_animations.dart';

final GlobalKey<_AnimatedTapButtonState> buttonKey = GlobalKey();

AnimatedTapButton(
  key: buttonKey,
  onTap: () async {
    // Handle tap
    bool success = await submitAnswer();
    
    if (success) {
      // Trigger bounce animation
      buttonKey.currentState?.triggerSuccessBounce();
    }
  },
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('Submit'),
  ),
)
```

### 3. XP Animations ✨

**Animated XP Counter** (Number counts up)

```dart
AnimatedXPCounter(
  startValue: 100,
  endValue: 150,
  duration: Duration(seconds: 2),
  textStyle: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.amber,
  ),
)
```

**Animated XP Progress Bar** (Smooth fill)

```dart
AnimatedXPBar(
  percent: 0.75, // 75%
  height: 12,
  progressColor: Colors.amber,
  showPercentText: false,
)
```

**Circular XP Progress**

```dart
AnimatedCircularXP(
  percent: 0.6, // 60%
  radius: 60,
  progressColor: Colors.purple,
  center: Text('Level 5'),
)
```

### 4. Level Up Animations 🎉

**Full-Screen Level Up with Confetti**

```dart
import 'package:quirzy/core/widgets/level_up_animation.dart';

// Show as overlay
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => LevelUpAnimation(
    newLevel: 5,
    xpEarned: 150,
    showConfetti: true,
    onComplete: () {
      Navigator.pop(context);
    },
  ),
);
```

**Compact Level Up Notification**

```dart
// Show as overlay positioned widget
Overlay.of(context).insert(
  OverlayEntry(
    builder: (context) => Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: CompactLevelUpNotification(newLevel: 3),
      ),
    ),
  ),
);
```

**XP Gain Popup**

```dart
// Show XP popup
Overlay.of(context).insert(
  OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: XPGainPopup(
          xpAmount: 25,
          reason: 'Correct Answer!',
        ),
      ),
    ),
  ),
);
```

### 5. Visual Effects 💫

**Pulsing Glow**

```dart
PulsingGlow(
  glowColor: Colors.purple,
  glowRadius: 20,
  child: Icon(Icons.star, size: 50),
)
```

**Success Ripple**

```dart
SuccessRipple(
  child: Icon(Icons.check_circle, size: 50, color: Colors.green),
)
```

**Shimmer Effect**

```dart
ShimmerEffect(
  duration: Duration(milliseconds: 1500),
  child: Text('Loading...'),
)
```

**Level Up Badge** (Animated badge with glow)

```dart
LevelUpBadge(
  level: 5,
  badgeColor: Colors.purple,
)
```

## 🚀 Implementation Examples

### Complete Quiz Question Screen Example

```dart
class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CountDownController _timerController = CountDownController();
  int xp = 100;

  void _onAnswerCorrect() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      xp += 25;
    });
    
    // Show XP gain popup
    _showXPGainPopup(25, 'Correct!');
    
    // Check for level up
    if (xp >= 200) {
      _showLevelUp(2);
    }
  }

  void _showXPGainPopup(int amount, String reason) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
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
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showLevelUp(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpAnimation(
        newLevel: newLevel,
        xpEarned: 100,
        onComplete: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: QuizCountdownTimer(
          duration: 30,
          controller: _timerController,
          onComplete: () {
            // Time up logic
          },
        ),
      ),
      body: Column(
        children: [
          // XP Progress Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: AnimatedXPBar(
              percent: xp / 200, // Assuming 200 XP per level
              height: 8,
            ),
          ),
          
          // Question and options...
          
          // Submit button with animations
          AnimatedTapButton(
            onTap: _onAnswerCorrect,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Submit Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Profile Screen XP Display

```dart
// In Profile Screen
Column(
  children: [
    // XP Counter
    AnimatedXPCounter(
      startValue: 0,
      endValue: currentXP,
      duration: Duration(seconds: 2),
    ),
    
    SizedBox(height: 16),
    
    // Level Progress
    AnimatedCircularXP(
      percent: (currentXP % 200) / 200, // Progress to next level
      radius: 80,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Level', style: TextStyle(fontSize: 12)),
          Text('$currentLevel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  ],
)
```

##  📝 Best Practices

1. **Performance**: Don't animate too many things at once
2. **Haptic Feedback**: Always pair important animations with HapticFeedback
3. **Timing**: Keep animations short and snappy (200-600ms for most)
4. **User Control**: Allow users to skip long animations
5. **Accessibility**: Provide alternative feedback for users who disable animations

## 🎨 Color Guidelines

- **Success**: Green tones
- **Warning**: Yellow/Amber
- **Danger**: Red tones  
- **Info**: Blue/Purple
- **XP/Rewards**: Amber/Gold
- **Level Up**: Purple/Gradient

## ⚡ Performance Tips

- Use `const` constructors where possible
- Dispose animation controllers properly
- Limit simultaneous animations to 3-4
- Use `RepaintBoundary` for complex animated widgets
- Consider using `AnimatedBuilder` for custom animations

---

**Made with ❤️ for Quirzy**
