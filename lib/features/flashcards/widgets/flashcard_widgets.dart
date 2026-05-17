import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// FlashcardCacheService - Manages local caching of flashcards
class FlashcardCacheService {
  static Future<void> init() async {
    // Initialize Hive box for flashcard caching
  }
}

/// FlashcardStudyScreen - Screen for studying flashcards
class FlashcardStudyScreen extends StatefulWidget {
  final String setId;
  final String title;
  final List<Map<String, dynamic>> cards;

  const FlashcardStudyScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.cards,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _knownCount = 0;
  int _unknownCount = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = widget.cards.isNotEmpty
        ? widget.cards[_currentIndex]
        : {'front': 'No cards', 'back': ''};

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF9F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.cards.isEmpty
          ? const Center(child: Text('No cards in this set'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress
                  Text(
                    'Card ${_currentIndex + 1} of ${widget.cards.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.cards.length,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    color: const Color(0xFF5B13EC),
                  ),
                  const SizedBox(height: 32),

                  // Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showAnswer = !_showAnswer),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(_showAnswer),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5B13EC).withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _showAnswer ? 'Answer' : 'Question',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5B13EC),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showAnswer
                                    ? card['back'] ?? ''
                                    : card['front'] ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Tap to flip',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_showAnswer)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _nextCard(false),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: Text(
                              'Still Learning',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _nextCard(true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: Text(
                              'Got It!',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade().slideY(begin: 0.2),
                ],
              ),
            ),
    );
  }

  void _nextCard(bool known) {
    if (known) {
      _knownCount++;
    } else {
      _unknownCount++;
    }

    if (_currentIndex < widget.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      // Show completion dialog
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete! 🎉'),
        content: Text('Known: $_knownCount\nStill Learning: $_unknownCount'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _showAnswer = false;
                _knownCount = 0;
                _unknownCount = 0;
              });
            },
            child: const Text('Study Again'),
          ),
        ],
      ),
    );
  }
}

/// ShimmerPlaceholders - Loading placeholders for lists
class ShimmerPlaceholders {
  static Widget historyList({int itemCount = 3}) {
    return Column(
      children: List.generate(
        itemCount,
        (index) =>
            Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: const Duration(seconds: 1)),
      ),
    );
  }

  static Widget flashcardSets({int itemCount = 3}) {
    return Column(
      children: List.generate(
        itemCount,
        (index) =>
            Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: const Duration(seconds: 1)),
      ),
    );
  }
}
