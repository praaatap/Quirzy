class User {
  final int id;
  final String username;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['name'] as String,
      email: json['email'] as String,
      avatar: json['profilePic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': username,
      'email': email,
      if (avatar != null) 'profilePic': avatar,
    };
  }

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
