import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final db = await DBService().connection;
      final results = await db.query(
        'SELECT username, role FROM users WHERE username = @u AND password = @p',
        substitutionValues: {'u': username, 'p': password},
      );

      if (results.isNotEmpty) {
        _user = User(username: results.first[0] as String, role: results.first[1] as String);
        _setLoading(false);
        return true;
      }
      _error = "Invalid credentials";
    } catch (e) {
      _error = "Connection Error: $e";
    }
    _setLoading(false);
    return false;
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      final db = await DBService().connection;
      // Check duplicate
      final check = await db.query('SELECT username FROM users WHERE username = @u', substitutionValues: {'u': username});
      if (check.isNotEmpty) {
        _error = "Username taken";
        _setLoading(false);
        return false;
      }
      
      await db.query('INSERT INTO users (username, password, role) VALUES (@u, @p, \'user\')', 
        substitutionValues: {'u': username, 'p': password});
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = "Register Error: $e";
      _setLoading(false);
      return false;
    }
  }

  Future<void> submitSupportTicket(String subject, String message) async {
    if (_user == null) return;
    try {
      final db = await DBService().connection;
      await db.query('INSERT INTO support_tickets (username, subject, message) VALUES (@u, @s, @m)',
        substitutionValues: {'u': _user!.username, 's': subject, 'm': message});
    } catch (e) { print(e); }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    _error = null;
    notifyListeners();
  }
}