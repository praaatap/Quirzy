// Export Enums & Models
export '../mascot/models/mascot_enums.dart';
export '../mascot/models/mascot_info.dart';
export '../mascot/models/mascot_dialogue.dart';

// Export Logic
export '../mascot/logic/mascot_controller.dart';

// Export Widgets
export '../mascot/widgets/mascot_display.dart';
// export '../mascot/widgets/mascot_selector.dart';
export '../mascot/widgets/floating_companion.dart';

// Backward Compatibility Layers
import '../mascot/widgets/mascot_display.dart';
import '../mascot/widgets/floating_companion.dart';
import '../mascot/models/mascot_enums.dart';
import 'package:flutter/material.dart';

class QuirzyMascotV2 extends MascotDisplay {
  const QuirzyMascotV2({
    super.key,
    super.character = MascotCharacter.quizzy,
    super.mood = MascotMood.idle,
    super.animation,
    super.size = 120,
    super.showSpeechBubble = false,
    super.customMessage,
    super.enableInteraction = true,
    super.onTap,
    super.autoAnimate = true,
  });
}

class FloatingCompanion extends FloatingCompanionWidget {
  const FloatingCompanion({super.key, super.alignment, super.onTap});
}
