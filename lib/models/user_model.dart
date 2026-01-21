class User {
  final int id;
  final String username;
  final String email;
  final String fullname;
  final String role;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullname,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullname: json['fullname'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullname': fullname,
      'role': role,
      'created_at': createdAt,
    };
  }
}
