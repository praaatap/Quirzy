/// App-wide configuration constants
class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'Quirzy';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '2';

  // Cache Settings
  static const int historyCacheTTL = 60; // minutes
  static const int statsCacheTTL = 30; // minutes
  static const int syncThreshold = 15; // minutes

  // Quiz Settings
  static const int defaultQuestionCount = 15;
  static const int maxFreeQuizzes = 5;

  // UI Settings
  static const double defaultBorderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
}
