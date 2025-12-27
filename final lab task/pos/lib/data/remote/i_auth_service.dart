// lib/domain/services/i_auth_service.dart

import '../models/user_profile.dart';

abstract class IAuthService {
  Future<void> signUp(UserProfile profile, String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}