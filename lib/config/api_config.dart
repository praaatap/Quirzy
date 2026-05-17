/// API Configuration - Backend service endpoints and settings
class ApiConfig {
  // Appwrite Configuration
  static const String appwriteEndpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '695be801003d58b523fc';

  // Database IDs
  static const String mainDatabaseId = '695d45fe000f2d83ddee';
  static const String storageBucketId = 'main_storage';
  
  // Collection IDs
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String quizResultsCollection = 'quiz_results';
  static const String flashcardsCollection = 'flashcards';
  static const String achievementsCollection = 'achievements';
  static const String leaderboardCollection = 'leaderboard';
  static const String studySessionsCollection = 'study_sessions';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'quirzy-bd6c3';
  static const String firebaseSenderId = '58516626621';
  
  // Gemini AI Configuration
  static const String geminiModel = 'gemini-pro';
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Ad Configuration
  static const String admobAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';
  static const String admobRewardedId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
  static const String admobInterstitialId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
  
  // Razorpay Configuration
  static const String razorpayKeyId = 'rzp_live_xxxxxxxxxx';
  static const String razorpayKeySecret = 'xxxxxxxxxxxxxx';
  
  // Timeout Settings
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // Retry Settings
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}
