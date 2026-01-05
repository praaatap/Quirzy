import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quirzy/core/services/study_service.dart';
import 'package:quirzy/features/study/screens/study_result_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudyInputScreen extends StatefulWidget {
  const StudyInputScreen({super.key});

  @override
  State<StudyInputScreen> createState() => _StudyInputScreenState();
}

class _StudyInputScreenState extends State<StudyInputScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<StudySet> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await StudyService().initialize();
    if (mounted) {
      setState(() {
        _history = StudyService().getHistory();
      });
    }
  }

  Future<void> _generateMagic() async {
    final text = _textController.text.trim();
    if (text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 50 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySet = await StudyService().generateStudySet(text);
      if (!mounted) return;

      // Navigate to results
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyResultScreen(studySet: studySet),
        ),
      );

      // Refresh history when returning
      _loadHistory();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openSet(StudySet set) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudyResultScreen(studySet: set)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Quirzy Brain 🧠',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
              onPressed: () async {
                await StudyService().clearHistory();
                _loadHistory();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInDown(
              child: Text(
                'Transform Notes into Knowledge',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Paste your lecture notes, article, or any text. We\'ll create a Podcast, Quiz, and Flashcards instantly.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 8,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Paste your text here...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateMagic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome),
                            const SizedBox(width: 8),
                            Text(
                              'Generate Magic',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            if (_history.isNotEmpty) ...[
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Recent Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ..._history.map((set) {
                return FadeInUp(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.history_edu,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        set.previewText?.trim() ?? 'Study Session',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        set.createdAt != null
                            ? timeago.format(set.createdAt!)
                            : 'Previously',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openSet(set),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
