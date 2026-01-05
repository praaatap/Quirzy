import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quirzy/core/services/podcast_service.dart';
import 'package:quirzy/core/services/study_service.dart';

class PodcastPlayerWidget extends StatefulWidget {
  final List<PodcastLine> script;

  const PodcastPlayerWidget({super.key, required this.script});

  @override
  State<PodcastPlayerWidget> createState() => _PodcastPlayerWidgetState();
}

class _PodcastPlayerWidgetState extends State<PodcastPlayerWidget> {
  late PodcastService _service;

  @override
  void initState() {
    super.initState();
    _service = PodcastService();
    _service.loadScript(widget.script);
  }

  @override
  void dispose() {
    _service.stop();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Consumer<PodcastService>(
        builder: (context, service, _) {
          final theme = Theme.of(context);
          final currentLine = service.currentIndex < widget.script.length
              ? widget.script[service.currentIndex]
              : null;
          final isPlaying = service.state == PodcastState.playing;

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.podcasts_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Podcast Overview',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'BETA',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Audio Visualizer Placehoder / Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isPlaying
                        ? (currentLine?.speaker == 'Host'
                              ? Colors.blue.shade100
                              : Colors.purple.shade100)
                        : Colors.grey.shade100,
                    child: Icon(
                      currentLine?.speaker == 'Host'
                          ? Icons.mic
                          : Icons.psychology,
                      size: 40,
                      color: isPlaying
                          ? (currentLine?.speaker == 'Host'
                                ? Colors.blue
                                : Colors.purple)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Speaker Name
                  Text(
                    currentLine?.speaker ?? 'Ready to Play',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Transcript
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          currentLine?.text ??
                              'Tap play to listen to an AI-generated conversation about your topic.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            fontStyle: currentLine == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // service.rewind(); // TODO
                        },
                        icon: const Icon(Icons.replay_10_rounded),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        onPressed: () {
                          if (isPlaying) {
                            service.pause();
                          } else {
                            service.play();
                          }
                        },
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          // service.forward(); // TODO
                        },
                        icon: const Icon(Icons.forward_10_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
