// Common extensions
extension DateTimeExtension on DateTime {
  String get timeAgo {
    final difference = DateTime.now().difference(this);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()} years ago';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} months ago';
    if (difference.inDays > 7) return '${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} minutes ago';
    return 'Just now';
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
  
  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');
  
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

extension IntExtension on int {
  String get toXPLabel => '$this XP';
  
  String get toCoinsLabel => '$this Coins';
  
  Duration get toSeconds => Duration(seconds: this);
  
  Duration get toMinutes => Duration(minutes: this);
}

extension DoubleExtension on double {
  String get toPercentage => '${toStringAsFixed(1)}%';
}

extension ListExtension on List<dynamic> {
  dynamic get random => this[DateTime.now().millisecondsSinceEpoch % length];
  
  List<dynamic> shuffleAndTake(int count) {
    final shuffled = List.from(this)..shuffle();
    return shuffled.take(count).toList();
  }
}
