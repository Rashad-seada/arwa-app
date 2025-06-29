class User {
  final String id;
  final String full_name;
  final String email;
  final String? photoUrl;

  User({
    required this.id,
    required this.full_name,
    required this.email,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      full_name: json['full_name'],
      email: json['email'],
      photoUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': full_name,
      'email': email,
      'avatar_url': photoUrl,
    };
  }
} 