class Comment {
  final int id;
  final String username;
  final String text;
  final DateTime date;

  Comment({required this.id, required this.username, required this.text, required this.date});
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
  int likes; // NEW

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.category,
    this.imagePath,
    this.isBookmarked = false,
    this.likes = 0, // NEW
  });

  String get readTime {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes min read';
  }
}