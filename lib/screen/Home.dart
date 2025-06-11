import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quirzy/widgets/customNavbar.dart';

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  PlatformFile? _selectedFile;
  int _currentIndex = 0;
  bool _isPickingFile = false;

  // Fixed file picking function with error handling
  Future<void> _pickDocument() async {
    if (_isPickingFile) return;
    
    setState(() => _isPickingFile = true);
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true, // Important for some platforms
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
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

  // 🧽 Clear selected file
  void _removeSelectedFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  // Handle navigation bar item taps
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Rest of your UI code remains exactly the same...
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
                'Describe your quiz idea or upload a document to generate a quiz.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // 📝 Input Area
              _selectedFile == null ? _buildTextInput() : _buildFilePreview(),

              const SizedBox(height: 20),

              // 📤 Upload Button
              _buildUploadButton(),

              const SizedBox(height: 20),

              // 🎯 Submit
              _buildGenerateQuizButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  // 🧾 Text Input Field
  Widget _buildTextInput() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const TextField(
        maxLines: null,
        decoration: InputDecoration.collapsed(
          hintText: "Start typing your quiz idea...",
        ),
      ),
    );
  }

  // 📎 File Preview Widget
  Widget _buildFilePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 30, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedFile!.name,
              style: GoogleFonts.poppins(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _removeSelectedFile,
          ),
        ],
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // ✅ Generate Quiz Button
  Widget _buildGenerateQuizButton() {
    return ElevatedButton(
      onPressed: () {
        // Your logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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