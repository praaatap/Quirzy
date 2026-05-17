// Canonical Appwrite client and config live in quiz_service.dart.
// All shared services import from here; this shim re-exports the real implementations.
export '../../features/quiz/services/quiz_service.dart' show AppwriteClient, AppwriteConfig;
