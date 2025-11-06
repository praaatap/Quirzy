class Challenge {
  final String id;
  final String challengerId;
  final String challengedId;
  final DateTime createdAt;
  final DateTime expiresAt;

  Challenge({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      challengerId: json['challengerId'],
      challengedId: json['challengedId'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}