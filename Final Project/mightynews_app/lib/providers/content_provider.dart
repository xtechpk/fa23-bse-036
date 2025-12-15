import 'package:flutter/material.dart';
// 👇 THIS WAS MISSING. IT IS REQUIRED.
import '../services/db_service.dart';
import '../models/models.dart';

class ContentProvider extends ChangeNotifier {
  List<BlogPost> _items = [];
  List<BlogPost> _savedItems = [];
  List<String> _categories = ['All'];
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<BlogPost> get items => [..._items];
  List<BlogPost> get savedItems => [..._savedItems];
  List<String> get categories => [..._categories];
  List<Comment> get comments => [..._comments];
  bool get isLoading => _isLoading;

  Future<void> fetchBlogs(int userId, {String? query, String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await DBService().connection;
      
      if (_categories.length == 1) {
        final cats = await db.query('SELECT name FROM categories');
        _categories = ['All'] + cats.map((e) => e[0] as String).toList();
      }

      String sql = '''
        SELECT b.id, b.title, b.content, b.author, b.created_at, b.category, b.image_path, b.likes_count,
        CASE WHEN bm.blog_id IS NOT NULL THEN true ELSE false END as is_bookmarked,
        CASE WHEN l.blog_id IS NOT NULL THEN true ELSE false END as is_liked
        FROM blogs b
        LEFT JOIN bookmarks bm ON b.id = bm.blog_id AND bm.user_id = @uid
        LEFT JOIN likes l ON b.id = l.blog_id AND l.user_id = @uid
      ''';
      
      List<String> whereClauses = [];
      Map<String, dynamic> values = {'uid': userId};

      if (query != null && query.isNotEmpty) {
        whereClauses.add('b.title ILIKE @q');
        values['q'] = '%$query%';
      }
      if (category != null && category != 'All') {
        whereClauses.add('b.category = @c');
        values['c'] = category;
      }

      if (whereClauses.isNotEmpty) sql += ' WHERE ${whereClauses.join(' AND ')}';
      sql += ' ORDER BY b.created_at DESC';

      final res = await db.query(sql, substitutionValues: values);
      
      _items = res.map((row) => BlogPost(
        id: row[0].toString(), title: row[1].toString(), content: row[2].toString(),
        author: row[3].toString(), date: row[4] as DateTime, category: row[5].toString(),
        imagePath: row[6]?.toString(), 
        likes: (row[7] as int?) ?? 0, 
        isBookmarked: (row[8] as bool?) ?? false,
        isLiked: (row[9] as bool?) ?? false,
      )).toList();

    } catch (e) { print(e); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(int userId, String blogId) async {
    final index = _items.indexWhere((i) => i.id == blogId);
    if (index == -1) return;

    final isLiked = _items[index].isLiked;
    final db = await DBService().connection;

    if (isLiked) {
      _items[index].likes--;
      _items[index].isLiked = false;
    } else {
      _items[index].likes++;
      _items[index].isLiked = true;
    }
    notifyListeners();

    try {
      if (isLiked) {
        await db.query('DELETE FROM likes WHERE user_id = @uid AND blog_id = @bid', substitutionValues: {'uid': userId, 'bid': blogId});
        await db.query('UPDATE blogs SET likes_count = likes_count - 1 WHERE id = @id', substitutionValues: {'id': blogId});
      } else {
        await db.query('INSERT INTO likes (user_id, blog_id) VALUES (@uid, @bid)', substitutionValues: {'uid': userId, 'bid': blogId});
        await db.query('UPDATE blogs SET likes_count = likes_count + 1 WHERE id = @id', substitutionValues: {'id': blogId});
      }
    } catch (e) { print(e); }
  }

  Future<void> fetchBookmarks(int userId) async {
    try {
      final db = await DBService().connection;
      final res = await db.query('''
        SELECT b.id, b.title, b.content, b.author, b.created_at, b.category, b.image_path, b.likes_count
        FROM blogs b
        JOIN bookmarks bm ON b.id = bm.blog_id
        WHERE bm.user_id = @uid
      ''', substitutionValues: {'uid': userId});

      _savedItems = res.map((row) => BlogPost(
        id: row[0].toString(), title: row[1].toString(), content: row[2].toString(),
        author: row[3].toString(), date: row[4] as DateTime, category: row[5].toString(),
        imagePath: row[6]?.toString(), likes: (row[7] as int?) ?? 0, isBookmarked: true, isLiked: false
      )).toList();
      notifyListeners();
    } catch (e) { print(e); }
  }

  Future<void> toggleBookmark(int userId, String blogId) async {
    final index = _items.indexWhere((i) => i.id == blogId);
    if (index != -1) {
      final isSaved = _items[index].isBookmarked;
      _items[index].isBookmarked = !isSaved;
      notifyListeners();
    }

    final db = await DBService().connection;
    try {
        final check = await db.query('SELECT id FROM bookmarks WHERE user_id = @uid AND blog_id = @bid', substitutionValues: {'uid': userId, 'bid': blogId});
        if (check.isNotEmpty) {
           await db.query('DELETE FROM bookmarks WHERE user_id = @uid AND blog_id = @bid', substitutionValues: {'uid': userId, 'bid': blogId});
        } else {
           await db.query('INSERT INTO bookmarks (user_id, blog_id) VALUES (@uid, @bid)', substitutionValues: {'uid': userId, 'bid': blogId});
        }
        await fetchBookmarks(userId);
    } catch(e) { print(e); }
  }

  Future<void> fetchComments(String blogId) async {
    final db = await DBService().connection;
    final res = await db.query('SELECT username, text, created_at FROM comments WHERE blog_id = @id ORDER BY created_at DESC', substitutionValues: {'id': blogId});
    _comments = res.map((r) => Comment(username: r[0] as String, text: r[1] as String, date: r[2] as DateTime)).toList();
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
      'INSERT INTO blogs (id, title, content, author, created_at, category, image_path, likes_count) VALUES (@id, @t, @c, @a, @d, @cat, @img, 0)',
      substitutionValues: {'id': b.id, 't': b.title, 'c': b.content, 'a': b.author, 'd': b.date, 'cat': b.category, 'img': b.imagePath}
    );
  }

  Future<void> deleteBlog(String id) async {
    final db = await DBService().connection;
    await db.query('DELETE FROM blogs WHERE id = @id', substitutionValues: {'id': id});
  }
}