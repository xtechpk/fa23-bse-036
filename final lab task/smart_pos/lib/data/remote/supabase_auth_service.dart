// lib/data/remote/supabase_auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUpWithProfile(UserProfile profile, String email, String password) async {
    try {
      // 1. Auth Signup
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 2. Profile Injection (OOP Encapsulation)
        await _client.from('profiles').insert(profile.toMap());
      }
    } catch (e) {
      throw Exception("Signup Failed: ${e.toString()}");
    }
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }
}