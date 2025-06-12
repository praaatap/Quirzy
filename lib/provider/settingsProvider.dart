import 'package:flutter_riverpod/flutter_riverpod.dart';

// Settings State Model
class SettingsState {
  final bool quizReminders;
  final bool appUpdates;
  final String theme;
  final String fontSize;
  final String language;

  const SettingsState({
    this.quizReminders = false,
    this.appUpdates = false,
    this.theme = 'Light',
    this.fontSize = 'Medium',
    this.language = 'English',
  });

  SettingsState copyWith({
    bool? quizReminders,
    bool? appUpdates,
    String? theme,
    String? fontSize,
    String? language,
  }) {
    return SettingsState(
      quizReminders: quizReminders ?? this.quizReminders,
      appUpdates: appUpdates ?? this.appUpdates,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
    );
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleQuizReminders(bool value) {
    state = state.copyWith(quizReminders: value);
  }

  void toggleAppUpdates(bool value) {
    state = state.copyWith(appUpdates: value);
  }

  void changeTheme(String theme) {
    state = state.copyWith(theme: theme);
  }

  void changeFontSize(String size) {
    state = state.copyWith(fontSize: size);
  }

  void changeLanguage(String lang) {
    state = state.copyWith(language: lang);
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);