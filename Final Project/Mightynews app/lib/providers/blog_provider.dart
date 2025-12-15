import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/app_models.dart';

class BlogProvider extends ChangeNotifier {
  List<BlogPost> _items = [];
  List<String> _categories = ['All'];
  List<Comment> _comments = [];
  bool _isLoading = true;

  List<BlogPost> get items => [..._items];
  List<String> get categories => [..._categories];
  List<Comment> get comments => [..._comments];
  bool get isLoading => _isLoading;

  Future<void> loadData({String? query, String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await DBService().connection;
      
      // 1. Fetch Categories
      final catResults = await db.query('SELECT name FROM categories');
      _categories = ['All'] + catResults.map((e) => e[0] as String).toList();

      // 2. Build Query
      String sql = 'SELECT * FROM blogs';
      List<String> conditions = [];
      Map<String, dynamic> values = {};

      if (query != null && query.isNotEmpty) {
        conditions.add('title ILIKE @q');
        values['q'] = '%$query%';
      }
      if (category != null && category != 'All') {
        conditions.add('category = @c');
        values['c'] = category;
      }
      if (conditions.isNotEmpty) sql += ' WHERE ${conditions.join(' AND ')}';
      sql += ' ORDER BY created_at DESC';

      final results = await db.query(sql, substitutionValues: values);
      
      _items = results.map((row) => BlogPost(
        id: row[0].toString(), title: row[1].toString(), content: row[2].toString(),
        author: row[3].toString(), date: row[4] as DateTime, category: row[5].toString(),
        imagePath: row[6]?.toString(), likes: (row[7] as int?) ?? 0, 
        isBookmarked: (row[8] as bool?) ?? false,
      )).toList();

    } catch (e) { print("Error: $e"); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> likePost(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].likes++;
      notifyListeners();
      final db = await DBService().connection;
      await db.query('UPDATE blogs SET likes_count = likes_count + 1 WHERE id = @id', substitutionValues: {'id': id});
    }
  }

  Future<void> fetchComments(String blogId) async {
    final db = await DBService().connection;
    final res = await db.query('SELECT id, username, text, created_at FROM comments WHERE blog_id = @id ORDER BY created_at DESC', substitutionValues: {'id': blogId});
    _comments = res.map((r) => Comment(id: r[0] as int, username: r[1] as String, text: r[2] as String, date: r[3] as DateTime)).toList();
    notifyListeners();
  }

  Future<void> addComment(String blogId, String username, String text) async {
    final db = await DBService().connection;
    await db.query('INSERT INTO comments (blog_id, username, text) VALUES (@bid, @u, @t)', substitutionValues: {'bid': blogId, 'u': username, 't': text});
    await fetchComments(blogId);
  }

  Future<void> addBlog(BlogPost b) async {
    final db = await DBService().connection;
    await db.query(
      'INSERT INTO blogs (id, title, content, author, created_at, category, image_path, likes_count, is_bookmarked) VALUES (@id, @t, @c, @a, @d, @cat, @img, 0, false)',
      substitutionValues: {'id': b.id, 't': b.title, 'c': b.content, 'a': b.author, 'd': b.date, 'cat': b.category, 'img': b.imagePath}
    );
    await loadData();
  }

  Future<void> deleteBlog(String id) async {
    final db = await DBService().connection;
    await db.query('DELETE FROM blogs WHERE id = @id', substitutionValues: {'id': id});
    await loadData();
  }
}