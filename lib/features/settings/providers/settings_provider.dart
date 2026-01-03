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
  final bool useSystemTheme;

  SettingsState({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.soundEnabled = true,
    this.darkMode = false,
    this.language = 'English',
    this.autoSaveProgress = true,
    this.useSystemTheme = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? darkMode,
    String? language,
    bool? autoSaveProgress,
    bool? useSystemTheme,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      autoSaveProgress: autoSaveProgress ?? this.autoSaveProgress,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
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
  // Cached instance for faster access
  SharedPreferences? _prefs;

  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  // Get cached or new instance
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _loadSettings() async {
    final prefs = await _getPrefs();

    state = SettingsState(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      emailNotifications: prefs.getBool('email_notifications') ?? true,
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      darkMode: prefs.getBool('dark_mode') ?? false,
      language: prefs.getString('language') ?? 'English',
      autoSaveProgress: prefs.getBool('auto_save') ?? true,
      useSystemTheme:
          prefs.getBool('use_system_theme') ?? !prefs.containsKey('dark_mode'),
    );
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await _getPrefs();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> toggleEmailNotifications(bool value) async {
    state = state.copyWith(emailNotifications: value);
    final prefs = await _getPrefs();
    await prefs.setBool('email_notifications', value);
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await _getPrefs();
    await prefs.setBool('sound_enabled', value);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkMode: value, useSystemTheme: false);
    final prefs = await _getPrefs();
    await prefs.setBool('dark_mode', value);
    await prefs.setBool('use_system_theme', false);
  }

  Future<void> setLanguage(String value) async {
    state = state.copyWith(language: value);
    final prefs = await _getPrefs();
    await prefs.setString('language', value);
  }

  Future<void> toggleAutoSave(bool value) async {
    state = state.copyWith(autoSaveProgress: value);
    final prefs = await _getPrefs();
    await prefs.setBool('auto_save', value);
  }
}
