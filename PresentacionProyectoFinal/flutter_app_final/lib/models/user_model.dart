class User {
  final String userId;
  final String name;
  final String email;
  final bool isAdmin;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      isAdmin: json['isAdmin'] == 1,
    );
  }
}
