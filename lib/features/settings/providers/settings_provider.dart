import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// SETTINGS STATE
// ==========================================

class SettingsState {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool soundEnabled;
  final bool darkMode;
  final String language;
  final bool autoSaveProgress;

  SettingsState({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.soundEnabled = true,
    this.darkMode = false,
    this.language = 'English',
    this.autoSaveProgress = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? darkMode,
    String? language,
    bool? autoSaveProgress,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      autoSaveProgress: autoSaveProgress ?? this.autoSaveProgress,
    );
  }
}

// ==========================================
// SETTINGS PROVIDER
// ==========================================

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = SettingsState(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      emailNotifications: prefs.getBool('email_notifications') ?? true,
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      darkMode: prefs.getBool('dark_mode') ?? false,
      language: prefs.getString('language') ?? 'English',
      autoSaveProgress: prefs.getBool('auto_save') ?? true,
    );
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> toggleEmailNotifications(bool value) async {
    state = state.copyWith(emailNotifications: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', value);
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> setLanguage(String value) async {
    state = state.copyWith(language: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  Future<void> toggleAutoSave(bool value) async {
    state = state.copyWith(autoSaveProgress: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save', value);
  }
}
