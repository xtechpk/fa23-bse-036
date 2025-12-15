class User {
  final String username;
  final String role;
  User({required this.username, required this.role});
  bool get isAdmin => role == 'admin';
}

class BlogPost {
  final String id;
  String title;
  String content;
  String author;
  DateTime date;
  String category;
  String? imagePath;
  bool isBookmarked;
  int likes;

  BlogPost({
    required this.id, required this.title, required this.content,
    required this.author, required this.date, required this.category,
    this.imagePath, this.isBookmarked = false, this.likes = 0,
  });

  String get readTime => '${(content.split(' ').length / 200).ceil()} min read';
}

class Comment {
  final int id;
  final String username;
  final String text;
  final DateTime date;
  Comment({required this.id, required this.username, required this.text, required this.date});
}