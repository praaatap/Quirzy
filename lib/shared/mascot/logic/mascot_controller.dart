import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mascot_enums.dart';

/// Mascot preference manager
class MascotPreferences {
  static const String _key = 'selected_mascot';

  static Future<MascotCharacter> getSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    return MascotCharacter.values[index.clamp(
      0,
      MascotCharacter.values.length - 1,
    )];
  }

  static Future<void> setSelected(MascotCharacter character) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, character.index);
  }
}

/// Mascot state provider
final mascotProvider = NotifierProvider<MascotNotifier, MascotCharacter>(
  MascotNotifier.new,
);

class MascotNotifier extends Notifier<MascotCharacter> {
  @override
  MascotCharacter build() {
    // Determine initial state (synchronous part)
    // We defer the async load to after build or handle it via a loading state if needed.
    // For simplicity, we start with default and update when prefs load.
    _loadMascot();
    return MascotCharacter.quizzy;
  }

  Future<void> _loadMascot() async {
    final character = await MascotPreferences.getSelected();
    state = character;
  }

  Future<void> setMascot(MascotCharacter character) async {
    state = character;
    await MascotPreferences.setSelected(character);
  }
}
