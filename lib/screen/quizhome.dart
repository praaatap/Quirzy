import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quirzy/screen/quizscreen.dart';

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final List<PlatformFile> _selectedFiles = [];
  late TextEditingController _textController;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Fixed file picking function with error handling
  Future<void> _pickDocument() async {
    if (_isPickingFile) return;

    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      debugPrint("File picking error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick file: ${e.toString()}")),
      );
    } finally {
      setState(() => _isPickingFile = false);
    }
  }

  void _removeSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QuizMaster',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.person_outline, size: 30),
                ],
              ),

              const SizedBox(height: 20),

              // 📘 Subtitle
              Text(
                'Describe your quiz idea or upload one or more documents to generate a quiz.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // 📝 Input Area (Always Visible)
              _buildTextInput(),

              const SizedBox(height: 20),

              // 📎 Files Preview Section
              if (_selectedFiles.isNotEmpty) _buildFilePreviewList(),

              const SizedBox(height: 20),

              // 📤 Upload Button
              _buildUploadButton(),

              const SizedBox(height: 20),

              // ✅ Generate Quiz Button
              _buildGenerateQuizButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 🧾 Text Input Field (always visible)
  Widget _buildTextInput() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        decoration: InputDecoration.collapsed(
          hintText: "Start typing your quiz idea...",
        ),
      ),
    );
  }

  // 📁 File Preview List (for multiple files)
  Widget _buildFilePreviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uploaded Documents (${_selectedFiles.length})",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedFiles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final file = _selectedFiles[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file, color: Colors.grey),
              title: Text(
                file.name,
                style: GoogleFonts.poppins(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeSelectedFile(index),
              ),
            );
          },
        ),
        if (_selectedFiles.isNotEmpty)
          TextButton.icon(
            onPressed: _clearAllFiles,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text("Clear All"),
          ),
      ],
    );
  }

  // 📤 Upload Button
  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _isPickingFile ? null : _pickDocument,
      icon: Icon(
        Icons.upload_rounded,
        color: _isPickingFile ? Colors.grey : Colors.black,
      ),
      label: Text(
        _isPickingFile ? "Uploading..." : "Upload Document",
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: _isPickingFile ? Colors.grey : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }


  // ✅ Generate Quiz Button
  Widget _buildGenerateQuizButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: animation,
                child: const Quizscreen(),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        'Generate Quiz',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
