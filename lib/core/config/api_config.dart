/// API configuration constants
class ApiConfig {
  ApiConfig._();

  // Backend API
  static const String baseUrl = 'https://quirzy-be.onrender.com';

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';
  static const String authGoogle = '/auth/google';
  static const String authVerify = '/auth/verify-token';

  static const String quizGenerate = '/quiz/generate';
  static const String quizGenerateFile = '/quiz/generate-from-file';
  static const String quizResults = '/quiz/results';
  static const String quizResult = '/quiz/result';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
