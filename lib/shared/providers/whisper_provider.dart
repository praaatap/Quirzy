import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/whisper_service.dart';

/// Provider for WhisperService singleton
final whisperServiceProvider = Provider<WhisperService>((ref) {
  return WhisperService.instance;
});

/// Provider for Whisper model download status
final whisperModelStatusProvider =
    ChangeNotifierProvider<WhisperModelStatusNotifier>((ref) {
      return WhisperModelStatusNotifier(ref.watch(whisperServiceProvider));
    });

/// Provider for download progress (0.0 - 1.0)
final whisperDownloadProgressProvider = StateProvider<double>((ref) => 0.0);

/// State notifier for Whisper model status using ChangeNotifier
class WhisperModelStatusNotifier extends ChangeNotifier {
  final WhisperService _service;
  WhisperModelStatus _status = WhisperModelStatus.notDownloaded;

  WhisperModelStatusNotifier(this._service) {
    _checkStatus();
  }

  WhisperModelStatus get status => _status;

  Future<void> _checkStatus() async {
    final isDownloaded = await _service.isModelDownloaded();
    _status = isDownloaded
        ? WhisperModelStatus.downloaded
        : WhisperModelStatus.notDownloaded;
    notifyListeners();
  }

  Future<void> downloadModel(void Function(double) onProgress) async {
    _status = WhisperModelStatus.downloading;
    notifyListeners();
    try {
      await _service.downloadModel(onProgress: onProgress);
      _status = WhisperModelStatus.downloaded;
      notifyListeners();
    } catch (e) {
      _status = WhisperModelStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _checkStatus();
  }
}

/// Provider for transcription state
final transcriptionProvider = StateProvider<String?>((ref) => null);

/// Provider for recording state
final isRecordingProvider = StateProvider<bool>((ref) => false);
