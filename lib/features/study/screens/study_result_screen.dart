import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quirzy/core/services/study_service.dart';
import 'package:quirzy/features/study/widgets/podcast_player_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// We'll reuse the MistakeFlashcardService's data model or create a generic one
// For now, we manually create visual cards. Future: Save to DB.

class StudyResultScreen extends StatefulWidget {
  final StudySet studySet;

  const StudyResultScreen({super.key, required this.studySet});

  @override
  State<StudyResultScreen> createState() => _StudyResultScreenState();
}

class _StudyResultScreenState extends State<StudyResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WakelockPlus.enable(); // Keep screen on while studying
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Allow screen to sleep again
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Your Study Set',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Podcast', icon: Icon(Icons.headphones_rounded)),
            Tab(text: 'Summary', icon: Icon(Icons.summarize_rounded)),
            Tab(text: 'Cards', icon: Icon(Icons.style_rounded)),
            Tab(text: 'Quiz', icon: Icon(Icons.quiz_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPodcastTab(),
          _buildSummaryTab(),
          _buildFlashcardsTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  Widget _buildPodcastTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          PodcastPlayerWidget(script: widget.studySet.podcastScript),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This audio is AI-generated based on your notes. It simulates a conversation to help you learn faster.',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Takeaways',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Simple Markdown-ish parsing or just text
          Text(
            widget.studySet.summary,
            style: GoogleFonts.poppins(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.studySet.flashcards.length,
      itemBuilder: (context, index) {
        final card = widget.studySet.flashcards[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(
                card.front,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: Text(
                    card.back,
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.studySet.quiz.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final q = widget.studySet.quiz[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q${index + 1}. ${q.questionText}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(q.options.length, (optIndex) {
                final isCorrect = optIndex == q.correctAnswer;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          String.fromCharCode(65 + optIndex),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[optIndex],
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
