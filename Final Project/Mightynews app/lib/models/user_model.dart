class User {
  final String username;
  final String role; // 'admin' or 'user'

  User({required this.username, required this.role});

  // Helper to check if admin
  bool get isAdmin => role == 'admin';
}