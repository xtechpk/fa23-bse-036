// lib/data/remote/supabase_auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUpWithProfile(UserProfile profile, String email, String password) async {
    try {
      // 1. Create the Auth User
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 2. Insert profile data into PostgreSQL
        // Note: Use the user ID from the auth response
        await _client.from('profiles').insert({
          'id': res.user!.id,
          'shop_name': profile.shopName,
          'ntn_number': profile.toMap()['ntn_number'],
          'phone_number': profile.toMap()['phone_number'],
          'address': profile.toMap()['address'],
          'branch_name': profile.toMap()['branch_name'],
          'role': profile.role.name,
        });
      }
    } on AuthException catch (e) {
      throw e.message; // Specifically catches the 400 error reasons
    } catch (e) {
      throw "An unexpected error occurred: $e";
    }
  }
}