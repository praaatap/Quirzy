import 'dart:math';
import 'mascot_enums.dart';

/// Motivational messages organized by context
class MascotDialogue {
  static final Random _random = Random();

  // Welcome messages per character
  static const Map<MascotCharacter, List<String>> welcomeMessages = {
    MascotCharacter.quizzy: [
      "Hoot hoot! Ready to learn? 🦉",
      "Knowledge awaits, my friend! 📚",
      "Let's make you wiser today! ✨",
      "Another day, another lesson! 🎓",
    ],
  };

  // Encouraging messages
  static const Map<MascotCharacter, List<String>> encouragingMessages = {
    MascotCharacter.quizzy: [
      "Wise choice, keep going! 🦉",
      "You're learning so much! 📚",
      "Every question makes you smarter! 🧠",
      "I believe in you! ✨",
    ],
  };

  // Celebration messages
  static const Map<MascotCharacter, List<String>> celebrationMessages = {
    MascotCharacter.quizzy: [
      "Outstanding wisdom! 🎓",
      "A true scholar! 🦉",
      "Knowledge mastered! 🏆",
      "Brilliant! 🌟",
    ],
  };

  // Sad/comfort messages
  static const Map<MascotCharacter, List<String>> comfortMessages = {
    MascotCharacter.quizzy: [
      "Every mistake teaches something 📚",
      "Wisdom comes from trying 🦉",
      "Let's review together ✨",
      "You'll get it next time! 💙",
    ],
  };

  // Thinking/loading messages
  static const Map<MascotCharacter, List<String>> thinkingMessages = {
    MascotCharacter.quizzy: [
      "Hmm, let me think... 🤔",
      "Consulting my wisdom... 📚",
      "Processing knowledge... 🦉",
    ],
  };

  static String getMessage(MascotCharacter character, MascotMood mood) {
    List<String> messages;

    switch (mood) {
      case MascotMood.happy:
      case MascotMood.waving:
      case MascotMood.idle:
        messages = welcomeMessages[character]!;
        break;
      case MascotMood.encouraging:
      case MascotMood.studying:
        messages = encouragingMessages[character]!;
        break;
      case MascotMood.celebrating:
      case MascotMood.excited:
      case MascotMood.proud:
        messages = celebrationMessages[character]!;
        break;
      case MascotMood.sad:
      case MascotMood.confused:
        messages = comfortMessages[character]!;
        break;
      case MascotMood.thinking:
        messages = thinkingMessages[character]!;
        break;
      default:
        messages = welcomeMessages[character]!;
    }

    return messages[_random.nextInt(messages.length)];
  }
}
