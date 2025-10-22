// 1.1 MODELS (lib/data/models/user.dart)
// ---------------------
class User {
  final int userId;
  final String email;
  String name;
  double? cumulativeGpa; // Optional: Previous CGPA

  User(
      {required this.userId,
      required this.email,
      required this.name,
      this.cumulativeGpa});

  // Factory constructor to create a User from API response JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      // API might return null for cumulative_gpa
      cumulativeGpa: (json['cumulative_gpa'] as num?)?.toDouble(),
    );
  }
}
