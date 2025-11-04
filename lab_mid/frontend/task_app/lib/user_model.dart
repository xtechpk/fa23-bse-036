import 'dart:convert';

class User {
  final String id;
  final String? username;
  final String email;

  User({
    required this.id,
    this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }

  static User fromJsonString(String jsonString) =>
      User.fromJson(json.decode(jsonString));
  String toJsonString() => json.encode(toJson());
}
