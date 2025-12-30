import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final String navbarStyle;

  SettingsState({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.soundEnabled = true,
    this.darkMode = false,
    this.language = 'English',
    this.autoSaveProgress = true,
    this.navbarStyle = 'material',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? soundEnabled,
    bool? darkMode,
    String? language,
    bool? autoSaveProgress,
    String? navbarStyle,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      autoSaveProgress: autoSaveProgress ?? this.autoSaveProgress,
      navbarStyle: navbarStyle ?? this.navbarStyle,
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
  final _storage = const FlutterSecureStorage();

  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final notifications = await _storage.read(key: 'notifications_enabled');
    final emailNotif = await _storage.read(key: 'email_notifications');
    final sound = await _storage.read(key: 'sound_enabled');
    final darkMode = await _storage.read(key: 'dark_mode');
    final language = await _storage.read(key: 'language');
    final autoSave = await _storage.read(key: 'auto_save');
    final navbarStyle = await _storage.read(key: 'navbar_style');

    state = SettingsState(
      notificationsEnabled: notifications == 'true',
      emailNotifications: emailNotif != 'false',
      soundEnabled: sound != 'false',
      darkMode: darkMode == 'true',
      language: language ?? 'English',
      autoSaveProgress: autoSave != 'false',
      navbarStyle: navbarStyle ?? 'material',
    );
  }

  Future<void> toggleNotifications(bool value) async {
    await _storage.write(key: 'notifications_enabled', value: value.toString());
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> toggleEmailNotifications(bool value) async {
    await _storage.write(key: 'email_notifications', value: value.toString());
    state = state.copyWith(emailNotifications: value);
  }

  Future<void> toggleSound(bool value) async {
    await _storage.write(key: 'sound_enabled', value: value.toString());
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> toggleDarkMode(bool value) async {
    await _storage.write(key: 'dark_mode', value: value.toString());
    state = state.copyWith(darkMode: value);
  }

  Future<void> setLanguage(String value) async {
    await _storage.write(key: 'language', value: value);
    state = state.copyWith(language: value);
  }

  Future<void> toggleAutoSave(bool value) async {
    await _storage.write(key: 'auto_save', value: value.toString());
    state = state.copyWith(autoSaveProgress: value);
  }

  Future<void> setNavbarStyle(String style) async {
    await _storage.write(key: 'navbar_style', value: style);
    state = state.copyWith(navbarStyle: style);
  }
}
