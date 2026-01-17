import '../models/mascot_enums.dart';
import '../models/mascot_info.dart';
import 'mascot_painter_strategy.dart';
import 'owl_painter.dart';

class MascotPainterFactory {
  static MascotPainterStrategy getPainter(
    MascotCharacter character,
    MascotMood mood,
  ) {
    final info = MascotInfo.get(character);

    if (character == MascotCharacter.quizzy) {
      return OwlPainter(character: character, mood: mood, info: info);
    }
    // Default fallback
    return OwlPainter(character: character, mood: mood, info: info);
  }
}
