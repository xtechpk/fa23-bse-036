import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart'; 
import '../local/db_helper.dart';

class AuthService {
  final _client = Supabase.instance.client;
  final _db = DBHelper();

  Future<void> signUp(String email, String password) async {
    try {
      // 1. Online Mode: Supabase Auth Signup 
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 2. Offline Mode: Store the ID in local SQLite 
        final db = await _db.database;
        await db.insert(
          'profile', 
          {
            'id': res.user!.id,
            'shop_name': '',
            'ntn_number': '',
            'phone_number': '',
            'address': ''
          }, 
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
    } on AuthException catch (e) {
      throw e.message; 
    } catch (e) {
      throw "Signup failed. Please check your internet connection.";
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    }
  }
}