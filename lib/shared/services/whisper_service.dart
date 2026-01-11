import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

/// Whisper model status enum
enum WhisperModelStatus { notDownloaded, downloading, downloaded, error }

/// Service for managing Whisper model download and transcription
class WhisperService {
  static WhisperService? _instance;
  Whisper? _whisper;

  static const String _modelDownloadedKey = 'whisper_model_downloaded';
  static const String _downloadHost =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/main';

  // Using base model for good accuracy/size balance (~150MB)
  static const WhisperModel _selectedModel = WhisperModel.base;

  WhisperService._();

  static WhisperService get instance {
    _instance ??= WhisperService._();
    return _instance!;
  }

  /// Check if the Whisper model has been downloaded
  Future<bool> isModelDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_modelDownloadedKey) ?? false;
  }

  /// Get the model file size for display
  String getModelSizeDisplay() {
    switch (_selectedModel) {
      case WhisperModel.tiny:
        return '~75 MB';
      case WhisperModel.base:
        return '~150 MB';
      case WhisperModel.small:
        return '~500 MB';
      case WhisperModel.medium:
        return '~1.5 GB';
      case WhisperModel.largeV1:
        return '~3 GB';
      case WhisperModel.largeV2:
        return '~3 GB';
      default:
        return '~150 MB';
    }
  }

  /// Initialize Whisper with model download
  /// The whisper_flutter_new package handles download internally
  Future<void> downloadModel({
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Initialize whisper - this triggers model download if not present
      _whisper = Whisper(model: _selectedModel, downloadHost: _downloadHost);

      // The package downloads on first use, so we trigger a version check
      // to initiate the download
      final version = await _whisper!.getVersion();
      debugPrint('Whisper initialized, version: $version');

      // Mark as downloaded
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelDownloadedKey, true);

      onProgress?.call(1.0);
    } catch (e) {
      debugPrint('Error downloading Whisper model: $e');
      rethrow;
    }
  }

  /// Initialize Whisper if model is already downloaded
  Future<void> initialize() async {
    if (_whisper != null) return;

    final isDownloaded = await isModelDownloaded();
    if (!isDownloaded) {
      throw Exception('Whisper model not downloaded');
    }

    _whisper = Whisper(model: _selectedModel, downloadHost: _downloadHost);

    // Clean up old recordings on init
    cleanupRecordings();
  }

  /// Transcribe audio file to text
  /// Audio must be 16kHz mono WAV format
  Future<String> transcribe(String audioPath) async {
    if (_whisper == null) {
      await initialize();
    }

    try {
      final result = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false, // Keep original language
          isNoTimestamps: true, // We don't need timestamps
          splitOnWord: false,
        ),
      );

      // The result is a WhisperTranscribeResponse, extract the text
      return result.text.trim();
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      rethrow;
    }
  }

  /// Get the audio recording directory path
  Future<String> getRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingDir = Directory('${directory.path}/recordings');
    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: true);
    }
    return '${recordingDir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  /// Clean up old recordings
  Future<void> cleanupRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingDir = Directory('${directory.path}/recordings');
      if (await recordingDir.exists()) {
        final files = await recordingDir.list().toList();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up recordings: $e');
    }
  }

  /// Reset model download status (for debugging/re-download)
  Future<void> resetModelStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_modelDownloadedKey);
    _whisper = null;
  }
}
