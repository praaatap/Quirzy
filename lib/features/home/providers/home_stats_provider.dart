import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../quiz/providers/quiz_providers.dart';

class HomeStats {
  final int streak;
  final int xpToday;
  final int quizzesToday;

  const HomeStats({this.streak = 0, this.xpToday = 0, this.quizzesToday = 0});
}

final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final dailyQuizService = ref.read(dailyQuizServiceProvider);

  final streak = prefs.getInt('daily_streak') ?? 0;
  final quizzesToday = await dailyQuizService.getDailyQuizCount();
  final xpToday = await dailyQuizService.getXPToday();

  return HomeStats(
    streak: streak,
    xpToday: xpToday,
    quizzesToday: quizzesToday,
  );
});
