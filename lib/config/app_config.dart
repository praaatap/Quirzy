/// App Configuration - Environment and build settings
class AppConfig {
  // App Info
  static const String appName = 'Quirzy';
  static const String appVersion = '2.1.2';
  static const int buildNumber = 6;
  
  // Environment
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
  static const bool isProduction = !isDebug;
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.quirzy.com';
  static const String aiApiUrl = 'https://generativelanguage.googleapis.com';
  
  // Feature Flags
  static const bool enableAds = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Limits
  static const int freeQuizLimit = 2;
  static const int freeFlashcardLimit = 53;
  static const int maxQuestionCount = 20;
  static const int minQuestionCount = 5;
  static const int cacheExpiryDays = 30;
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int imageUploadTimeoutSeconds = 60;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
