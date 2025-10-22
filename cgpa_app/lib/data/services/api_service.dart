// ---------------------
// 1.3 SERVICE (lib/data/services/api_service.dart)
// This class simulates the connection to your API server which then talks to PostgreSQL.
// ---------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../models/user.dart';

class ApiService {
  // *** CONFIGURATION FOR THE FLUTTER CLIENT ***
  // NOTE: This MUST be the URL of YOUR backend API server (e.g., Express, Flask)

  // Default base URL for local development.
  // If you're using Android emulator, change this to 'http://10.0.2.2:3000/api/v1'
  // If you're using a real device, set this to your machine's LAN IP.
  static const String kBaseUrl = 'http://localhost:3000/api/v1';

  // Simulated API Data and State (kept as a fallback)
  User? _currentUser;
  User? get currentUser => _currentUser;

  // A map to simulate the database and user tokens/sessions (fallback only)
  final Map<String, User> _simulatedDb = {
    'test@example.com': User(
      userId: 1,
      email: 'test@example.com',
      name: 'Test User',
      cumulativeGpa: 3.5,
    ),
  };

  final Map<String, String> _passwords = {
    'test@example.com': 'password123',
  };

  // Helper to call backend with proper error handling
  Future<http.Response> _httpPost(
      String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$kBaseUrl$path');
    return await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
  }

  Future<http.Response> _httpPut(String path, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse('$kBaseUrl$path');
    final h = {'Content-Type': 'application/json'};
    if (headers != null) h.addAll(headers);
    return await http
        .put(uri, headers: h, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
  }

  // --- Public API Methods (HTTP-backed; fallback to simulated on network error) ---

  Future<User> signIn(String email, String password) async {
    try {
      final resp = await _httpPost(
          '/auth/login', {'email': email, 'password': password});
      if (resp.statusCode == 200) {
        final Map<String, dynamic> payload = jsonDecode(resp.body);
        final data = payload['data'] as Map<String, dynamic>;
        final user = User.fromJson(data);
        _currentUser = user;
        return user;
      }
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Login failed');
    } catch (e) {
      // network or parse error -> fallback to simulated
      developer.log('signIn HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      // simulated logic
      final raw = email;
      final em = raw.trim().toLowerCase();
      final user = _simulatedDb[em];
      final expected = _passwords[em];
      if (user != null && expected != null && password == expected) {
        _currentUser = user;
        return user;
      }
      throw Exception('Invalid credentials.');
    }
  }

  Future<User> signUp(String name, String email, String password) async {
    try {
      final resp = await _httpPost(
          '/auth/signup', {'name': name, 'email': email, 'password': password});
      if (resp.statusCode == 201) {
        final Map<String, dynamic> payload = jsonDecode(resp.body);
        final data = payload['data'] as Map<String, dynamic>;
        final user = User.fromJson(data);
        _currentUser = user;
        return user;
      }
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Sign up failed');
    } catch (e) {
      developer.log('signUp HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      final rawEmail = email;
      final em = rawEmail.trim().toLowerCase();
      if (em.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required.');
      }
      if (_simulatedDb.containsKey(em)) {
        throw Exception('Email already registered.');
      }
      final newUser = User(
          userId: _simulatedDb.length + 1,
          email: em,
          name: name,
          cumulativeGpa: null);
      _simulatedDb[em] = newUser;
      _passwords[em] = password;
      _currentUser = newUser;
      return newUser;
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      final resp = await _httpPost('/auth/forgot-password', {'email': email});
      if (resp.statusCode == 200) return;
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Password reset failed.');
    } catch (e) {
      developer.log('forgotPassword HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      final em = email.trim().toLowerCase();
      if (!_simulatedDb.containsKey(em)) {
        throw Exception('User not found.');
      }
      return;
    }
  }

  Future<void> updateProfile(String newName) async {
    if (_currentUser == null) throw Exception('Unauthorized');
    try {
      final resp = await _httpPut(
          '/profile/${_currentUser!.userId}', {'name': newName},
          headers: {'X-User-Id': '${_currentUser!.userId}'});
      if (resp.statusCode == 200) {
        _currentUser!.name = newName;
        return;
      }
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Profile update failed.');
    } catch (e) {
      developer.log('updateProfile HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      _currentUser!.name = newName;
      _simulatedDb[_currentUser!.email] = _currentUser!;
      return;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    if (_currentUser == null) throw Exception('Unauthorized');
    try {
      final resp = await _httpPut(
          '/profile/${_currentUser!.userId}/email', {'email': newEmail},
          headers: {'X-User-Id': '${_currentUser!.userId}'});
      if (resp.statusCode == 200) {
        // update local user
        final old = _currentUser!.email;
        _currentUser = User(
            userId: _currentUser!.userId,
            email: newEmail,
            name: _currentUser!.name,
            cumulativeGpa: _currentUser!.cumulativeGpa);
        _simulatedDb.remove(old);
        _simulatedDb[newEmail.toLowerCase()] = _currentUser!;
        return;
      }
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Email update failed.');
    } catch (e) {
      developer.log('updateEmail HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      final rawNew = newEmail;
      final em = rawNew.trim().toLowerCase();
      if (em.isEmpty) {
        throw Exception('Email required.');
      }
      if (_simulatedDb.containsKey(em)) {
        throw Exception('Email already in use.');
      }
      final oldEmail = _currentUser!.email;
      final pwd = _passwords.remove(oldEmail);
      final updatedUser = User(
          userId: _currentUser!.userId,
          email: em,
          name: _currentUser!.name,
          cumulativeGpa: _currentUser!.cumulativeGpa);
      _currentUser = updatedUser;
      _simulatedDb[em] = updatedUser;
      if (pwd != null) _passwords[em] = pwd;
      return;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (_currentUser == null) throw Exception('Unauthorized');
    try {
      final resp = await _httpPut('/profile/${_currentUser!.userId}/password',
          {'password': newPassword},
          headers: {'X-User-Id': '${_currentUser!.userId}'});
      if (resp.statusCode == 200) return;
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'Password update failed.');
    } catch (e) {
      developer.log('updatePassword HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      _passwords[_currentUser!.email] = newPassword;
      return;
    }
  }

  Future<void> updatePreviousCgpa(double? cgpa) async {
    if (_currentUser == null) throw Exception('Unauthorized');
    try {
      final resp = await _httpPut(
          '/profile/${_currentUser!.userId}/cgpa', {'cumulative_gpa': cgpa},
          headers: {'X-User-Id': '${_currentUser!.userId}'});
      if (resp.statusCode == 200) {
        _currentUser!.cumulativeGpa = cgpa;
        return;
      }
      final Map<String, dynamic> err = jsonDecode(resp.body);
      throw Exception(err['message'] ?? 'CGPA update failed.');
    } catch (e) {
      developer.log(
          'updatePreviousCgpa HTTP failed, falling back to simulated: $e',
          name: 'ApiService');
      _currentUser!.cumulativeGpa = cgpa;
      _simulatedDb[_currentUser!.email] = _currentUser!;
      return;
    }
  }
}
