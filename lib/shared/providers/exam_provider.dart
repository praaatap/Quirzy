import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final examProvider = NotifierProvider<ExamNotifier, String?>(ExamNotifier.new);

class ExamNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Determine initial state
    _loadExam();
    return null;
  }

  Future<void> _loadExam() async {
    final prefs = await SharedPreferences.getInstance();
    final exam = prefs.getString('selected_exam');
    state = exam;
  }

  Future<void> setExam(String exam) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_exam', exam);
    state = exam;
  }

  bool get hasSelected => state != null;
}
