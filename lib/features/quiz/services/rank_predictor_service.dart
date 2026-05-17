class RankPrediction {
  final String examType;
  final double score; // percentage 0–100
  final int estimatedRankLow;
  final int estimatedRankHigh;
  final double percentileLow;
  final double percentileHigh;
  final String category; // 'Top 1%', 'Top 10%' etc
  final String message;
  final List<String> improvementTips;
  final Map<String, double> cutoffs; // college/category → min percentile

  const RankPrediction({
    required this.examType,
    required this.score,
    required this.estimatedRankLow,
    required this.estimatedRankHigh,
    required this.percentileLow,
    required this.percentileHigh,
    required this.category,
    required this.message,
    required this.improvementTips,
    required this.cutoffs,
  });
}

/// Estimates rank and percentile based on score percentage.
/// Uses realistic approximation distributions seeded from historical cutoff data.
class RankPredictorService {
  static RankPrediction predict({
    required String examType,
    required double scorePercent, // 0–100
    required int totalQuestions,
  }) {
    final exam = examType.toUpperCase();
    final config = _examData[exam] ?? _examData['General']!;

    final total = config['totalApplicants'] as int;
    final pctLow = _estimatePercentile(scorePercent, config).clamp(0.0, 99.9);
    final pctHigh = (pctLow + 1.5).clamp(0.0, 99.9);

    final rankLow = ((1 - pctHigh / 100) * total).round().clamp(1, total);
    final rankHigh = ((1 - pctLow / 100) * total).round().clamp(rankLow, total);

    final category = _category(pctLow);
    final message = _message(exam, pctLow, scorePercent);
    final tips = _tips(exam, scorePercent);
    final cutoffs = Map<String, double>.from(config['cutoffs'] as Map);

    return RankPrediction(
      examType: exam,
      score: scorePercent,
      estimatedRankLow: rankLow,
      estimatedRankHigh: rankHigh,
      percentileLow: double.parse(pctLow.toStringAsFixed(1)),
      percentileHigh: double.parse(pctHigh.toStringAsFixed(1)),
      category: category,
      message: message,
      improvementTips: tips,
      cutoffs: cutoffs,
    );
  }

  /// Sigmoid-based percentile curve calibrated per exam difficulty distribution.
  static double _estimatePercentile(
      double score, Map<String, dynamic> config) {
    final mean = (config['meanScore'] as num).toDouble();
    final std = (config['stdScore'] as num).toDouble();
    final z = (score - mean) / std;
    // Φ(z) approximation
    final pct = _normalCdf(z) * 100;
    return pct.clamp(0.0, 99.9);
  }

  // Abramowitz & Stegun approximation for Φ(z)
  static double _normalCdf(double z) {
    const b1 = 0.319381530;
    const b2 = -0.356563782;
    const b3 = 1.781477937;
    const b4 = -1.821255978;
    const b5 = 1.330274429;
    const p = 0.2316419;
    final t = 1.0 / (1.0 + p * z.abs());
    final poly = t * (b1 + t * (b2 + t * (b3 + t * (b4 + t * b5))));
    final phi = 1.0 - (1.0 / (1.0 * 2.506628) * _exp(-0.5 * z * z)) * poly;
    return z >= 0 ? phi : 1 - phi;
  }

  static double _exp(double x) {
    // Simple exp wrapper (dart:math not imported here to keep lightweight)
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  static String _category(double pct) {
    if (pct >= 99) return 'Top 1%';
    if (pct >= 95) return 'Top 5%';
    if (pct >= 90) return 'Top 10%';
    if (pct >= 75) return 'Top 25%';
    if (pct >= 50) return 'Top 50%';
    return 'Below Average';
  }

  static String _message(String exam, double pct, double score) {
    if (pct >= 95) return 'Excellent! You\'re in the top ${100 - pct.toInt()}% of $exam applicants.';
    if (pct >= 80) return 'Great performance — you\'re ahead of ${pct.toInt()}% of test-takers.';
    if (pct >= 60) return 'Solid score. Consistent practice will push you into the top tier.';
    if (pct >= 40) return 'You\'re above average. Target weak sections for a big jump.';
    return 'Keep practising — every mock test improves your rank significantly.';
  }

  static List<String> _tips(String exam, double score) {
    final tips = <String>[];
    if (score < 90) tips.add('Attempt more mock tests — each one improves time management');
    if (score < 70) tips.add('Focus on high-weightage topics first, not breadth');
    if (score < 50) tips.add('Review incorrect answers before attempting new questions');
    tips.add('Use spaced repetition flashcards for formula-heavy topics');
    if (exam == 'JEE' || exam == 'NEET') {
      tips.add('Solve at least 5 PYQs per topic before each mock test');
    }
    if (exam == 'CAT' || exam == 'GMAT') {
      tips.add('Speed and accuracy both matter — practice time-boxed sections');
    }
    return tips.take(3).toList();
  }

  // Realistic distributions and applicant counts per exam
  static const Map<String, Map<String, dynamic>> _examData = {
    'JEE': {
      'totalApplicants': 1200000,
      'meanScore': 38.0,
      'stdScore': 22.0,
      'cutoffs': {
        'IIT (General)': 90.0,
        'NIT (General)': 75.0,
        'IIIT': 70.0,
        'State GFTIs': 60.0,
      },
    },
    'NEET': {
      'totalApplicants': 2000000,
      'meanScore': 42.0,
      'stdScore': 24.0,
      'cutoffs': {
        'AIIMS Delhi': 99.5,
        'Top Govt MBBS': 95.0,
        'State MBBS Quota': 80.0,
        'BDS Colleges': 65.0,
      },
    },
    'CAT': {
      'totalApplicants': 300000,
      'meanScore': 50.0,
      'stdScore': 20.0,
      'cutoffs': {
        'IIM Ahmedabad': 99.0,
        'IIM Bangalore': 98.5,
        'Top IIMs': 97.0,
        'New IIMs': 90.0,
      },
    },
    'GRE': {
      'totalApplicants': 400000,
      'meanScore': 55.0,
      'stdScore': 22.0,
      'cutoffs': {
        'MIT / Stanford': 92.0,
        'Top 50 US Univ': 80.0,
        'Top 100 US Univ': 65.0,
      },
    },
    'GMAT': {
      'totalApplicants': 200000,
      'meanScore': 52.0,
      'stdScore': 20.0,
      'cutoffs': {
        'Harvard MBA': 96.0,
        'Top 10 B-Schools': 90.0,
        'Top 30 B-Schools': 75.0,
      },
    },
    'CUET': {
      'totalApplicants': 1500000,
      'meanScore': 55.0,
      'stdScore': 22.0,
      'cutoffs': {
        'DU Top Colleges': 95.0,
        'BHU': 88.0,
        'Central Universities': 80.0,
      },
    },
    'IELTS': {
      'totalApplicants': 500000,
      'meanScore': 60.0,
      'stdScore': 18.0,
      'cutoffs': {
        'UK Tier-1 Visa': 75.0,
        'Australian PR': 70.0,
        'Canadian Study Permit': 65.0,
      },
    },
    'General': {
      'totalApplicants': 100000,
      'meanScore': 50.0,
      'stdScore': 20.0,
      'cutoffs': <String, double>{},
    },
  };
}
