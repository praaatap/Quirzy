import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quirzy/core/services/study_service.dart';

enum PodcastState { stopped, playing, paused, completed }

class PodcastService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  PodcastState _state = PodcastState.stopped;
  PodcastState get state => _state;

  List<PodcastLine> _script = [];
  int _currentIndex = 0;

  // Voice configurations
  // These are standard platform-agnostic adjustments
  // Ideally, we'd pick specific voices, but pitch/rate is safer for cross-platform
  static const double _hostPitch = 1.0;
  static const double _hostRate = 0.5; // Normal speed

  static const double _expertPitch = 0.8; // Deeper voice
  static const double _expertRate = 0.45; // Slightly slower, more thoughtful

  PodcastService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      _playNextLine();
    });

    _tts.setCancelHandler(() {
      if (_state != PodcastState.paused) {
        _state = PodcastState.stopped; // Only set stopped if meaningful
        notifyListeners();
      }
    });
  }

  void loadScript(List<PodcastLine> script) {
    _script = script;
    _currentIndex = 0;
    _state = PodcastState.stopped;
    notifyListeners();
  }

  Future<void> play() async {
    if (_script.isEmpty) return;

    // If completed or stopped, restart
    if (_state == PodcastState.completed || _state == PodcastState.stopped) {
      _currentIndex = 0;
    }

    _state = PodcastState.playing;
    notifyListeners();

    // If was paused, resume current line effectively by re-playing it
    // TTS doesn't truly "resume" mid-sentence well across platforms,
    // so re-playing the current line is cleaner.
    await _playLine(_script[_currentIndex]);
  }

  Future<void> pause() async {
    await _tts.stop();
    _state = PodcastState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = PodcastState.stopped;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> _playNextLine() async {
    if (_state != PodcastState.playing) return;

    _currentIndex++;
    if (_currentIndex < _script.length) {
      await _playLine(_script[_currentIndex]);
    } else {
      _state = PodcastState.completed;
      notifyListeners();
    }
  }

  Future<void> _playLine(PodcastLine line) async {
    notifyListeners(); // Update UI to highlight current line

    // Adjust voice based on speaker
    if (line.speaker == 'Host') {
      await _tts.setPitch(_hostPitch);
      await _tts.setSpeechRate(_hostRate);
    } else {
      // Expert
      await _tts.setPitch(_expertPitch);
      await _tts.setSpeechRate(_expertRate);
    }

    await _tts.speak(line.text);
  }

  int get currentIndex => _currentIndex;
  String? get currentSpeaker =>
      _currentIndex < _script.length ? _script[_currentIndex].speaker : null;
}
