import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 👇 THIS WAS MISSING. IT IS REQUIRED.
import '../services/db_service.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  User? _currentUser;

  bool get isDarkMode => _isDarkMode;
  User? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == 'admin';

  AppProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final db = await DBService().connection;
      final results = await db.query(
        'SELECT id, username, role FROM users WHERE username = @u AND password = @p',
        substitutionValues: {'u': username, 'p': password},
      );
      if (results.isNotEmpty) {
        final row = results.first;
        _currentUser = User(id: row[0] as int, username: row[1] as String, role: row[2] as String);
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> register(String username, String password) async {
    try {
      final db = await DBService().connection;
      final check = await db.query('SELECT id FROM users WHERE username = @u', substitutionValues: {'u': username});
      if (check.isNotEmpty) return false;

      await db.query('INSERT INTO users (username, password, role) VALUES (@u, @p, \'user\')', 
        substitutionValues: {'u': username, 'p': password});
      return true;
    } catch (e) { return false; }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  
  Future<void> submitTicket(String subject, String message) async {
    if (_currentUser == null) return;
    try {
      final db = await DBService().connection;
      await db.query('INSERT INTO support_tickets (username, subject, message) VALUES (@u, @s, @m)',
        substitutionValues: {'u': _currentUser!.username, 's': subject, 'm': message});
    } catch (e) { print(e); }
  }
}