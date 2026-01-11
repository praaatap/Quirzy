import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import '../../shared/services/whisper_service.dart';
import '../../routes/app_routes.dart';
import '../services/quiz_service.dart';

/// Conversation message model
class ConversationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ConversationMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Voice Quiz Screen with conversational UI
class VoiceQuizScreen extends ConsumerStatefulWidget {
  const VoiceQuizScreen({super.key});

  @override
  ConsumerState<VoiceQuizScreen> createState() => _VoiceQuizScreenState();
}

class _VoiceQuizScreenState extends ConsumerState<VoiceQuizScreen> {
  final List<ConversationMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isGeneratingQuiz = false;
  Timer? _amplitudeTimer;
  List<double> _recentAmplitudes = List.filled(7, 0.0);

  // Conversation state
  int _conversationStep = 0;
  String? _extractedTopic;
  int _questionCount = 15;
  String _difficulty = 'medium';

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startConversation() {
    _addAIMessage("Hi! 👋 What topic would you like to be quizzed on today?");
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(ConversationMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ConversationMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final path = await WhisperService.instance.getRecordingPath();

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });

        _startAmplitudeTracking();
        HapticFeedback.mediumImpact();
      } else {
        _showError('Microphone permission required');
      }
    } catch (e) {
      _showError('Failed to start recording');
    }
  }

  void _startAmplitudeTracking() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      final amplitude = await _audioRecorder.getAmplitude();
      final normalized = ((amplitude.current + 160) / 160).clamp(0.0, 1.0);

      setState(() {
        _recentAmplitudes.removeAt(0);
        _recentAmplitudes.add(normalized);
      });
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _amplitudeTimer?.cancel();

    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      HapticFeedback.lightImpact();

      if (path != null) {
        await _processRecording(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showError('Failed to process recording');
    }
  }

  Future<void> _processRecording(String path) async {
    try {
      final transcription = await WhisperService.instance.transcribe(path);

      setState(() {
        _isProcessing = false;
      });

      if (transcription.isNotEmpty) {
        _addUserMessage(transcription);
        await _handleUserResponse(transcription);
      } else {
        _addAIMessage("I couldn't hear that clearly. Could you try again?");
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _addAIMessage(
        "Sorry, I had trouble understanding that. Please try again.",
      );
    }
  }

  Future<void> _handleUserResponse(String response) async {
    final lowerResponse = response.toLowerCase();

    switch (_conversationStep) {
      case 0: // Topic extraction
        // Simple cleanup to extract the core topic
        String topic = response;
        final prefixes = [
          'i want a quiz about',
          'i want a quiz on',
          'quiz about',
          'quiz on',
          'about',
          'on',
        ];

        for (final prefix in prefixes) {
          if (lowerResponse.startsWith(prefix)) {
            topic = response.substring(prefix.length).trim();
            break;
          }
        }

        // Remove trailing punctuation
        topic = topic.replaceAll(RegExp(r'[.!?]+$'), '');

        _extractedTopic = topic.isEmpty
            ? response
            : topic; // Fallback to original
        _conversationStep = 1;

        await Future.delayed(const Duration(milliseconds: 500));
        _addAIMessage(
          "Great choice! 📚 \"$_extractedTopic\"\n\nHow many questions would you like? (5, 10, 15, or 20)",
        );
        break;

      case 1: // Question count
        if (lowerResponse.contains('5')) {
          _questionCount = 5;
        } else if (lowerResponse.contains('10')) {
          _questionCount = 10;
        } else if (lowerResponse.contains('20')) {
          _questionCount = 20;
        } else {
          _questionCount = 15;
        }
        _conversationStep = 2;

        await Future.delayed(const Duration(milliseconds: 500));
        _addAIMessage(
          "$_questionCount questions it is! 🎯\n\nWhat difficulty level? (Easy, Medium, or Hard)",
        );
        break;

      case 2: // Difficulty
        if (lowerResponse.contains('easy')) {
          _difficulty = 'easy';
        } else if (lowerResponse.contains('hard')) {
          _difficulty = 'hard';
        } else {
          _difficulty = 'medium';
        }
        _conversationStep = 3;

        await Future.delayed(const Duration(milliseconds: 500));
        _addAIMessage(
          "Perfect! Here's your quiz setup:\n\n📖 Topic: $_extractedTopic\n📝 Questions: $_questionCount\n⚡ Difficulty: ${_difficulty.toUpperCase()}\n\nGenerating your quiz now...",
        );

        await _generateQuiz();
        break;
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isGeneratingQuiz = true;
    });

    try {
      final quizService = QuizService();
      final result = await quizService.generateQuiz(
        topic: _extractedTopic!,
        questionCount: _questionCount,
        difficulty: _difficulty,
      );

      if (mounted) {
        context.go(
          AppRoutes.quiz,
          extra: {
            'quizTitle': result['title'] ?? _extractedTopic,
            'quizId': result['quizId'] ?? '',
            'questions': result['questions'] ?? [],
            'difficulty': _difficulty,
          },
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingQuiz = false;
      });
      _addAIMessage(
        "Oops! Something went wrong generating your quiz. Would you like to try a different topic?",
      );
      _conversationStep = 0;
      _extractedTopic = null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _resetConversation() {
    setState(() {
      _messages.clear();
      _conversationStep = 0;
      _extractedTopic = null;
      _questionCount = 15;
      _difficulty = 'medium';
    });
    _startConversation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Voice Quiz',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: _resetConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(
                      begin: message.isUser ? 0.1 : -0.1,
                      duration: 300.ms,
                    );
              },
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          // Quiz generation indicator
          if (_isGeneratingQuiz)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF5B13EC),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Generating your quiz...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          // Recording Button
          if (!_isGeneratingQuiz)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Recording waveform indicator
                  if (_isRecording)
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          7,
                          (index) => _WaveformBar(
                            index: index,
                            isRecording: _isRecording,
                            amplitude: _recentAmplitudes[index],
                          ),
                        ),
                      ),
                    ),

                  // Record button
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isRecording ? 80 : 72,
                      height: _isRecording ? 80 : 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [Colors.redAccent, Colors.red]
                              : [
                                  const Color(0xFF5B13EC),
                                  const Color(0xFF7C3AED),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isRecording
                                        ? Colors.red
                                        : const Color(0xFF5B13EC))
                                    .withOpacity(0.4),
                            blurRadius: _isRecording ? 24 : 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _isRecording ? 'Release to send' : 'Hold to speak',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF5B13EC)
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            height: 1.4,
            color: message.isUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

/// Animated waveform bar for recording indicator
class _WaveformBar extends StatefulWidget {
  final int index;
  final bool isRecording;
  final double amplitude;

  const _WaveformBar({
    required this.index,
    required this.isRecording,
    this.amplitude = 0.5,
  });

  @override
  State<_WaveformBar> createState() => _WaveformBarState();
}

class _WaveformBarState extends State<_WaveformBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
    );

    _animation = Tween<double>(
      begin: 8,
      end: 32,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_WaveformBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Use amplitude to scale height if recording, otherwise use animation
        final double height = widget.isRecording
            ? 10 + (widget.amplitude * 40)
            : _animation.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: height,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
