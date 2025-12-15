class User {
  final int id;
  final String username;
  final String role;
  
  User({required this.id, required this.username, required this.role});
  
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
  int likes;
  bool isBookmarked; 
  bool isLiked; // NEW: Tracks if current user liked it

  BlogPost({
    required this.id, required this.title, required this.content,
    required this.author, required this.date, required this.category,
    this.imagePath, this.likes = 0, 
    this.isBookmarked = false,
    this.isLiked = false, // Default false
  });

  String get readTime {
    final minutes = (content.split(' ').length / 200).ceil();
    return '$minutes min read';
  }
}

class Comment {
  final String username;
  final String text;
  final DateTime date;
  
  Comment({required this.username, required this.text, required this.date});
}