import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:task_app/user_model.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: 'current_user', value: user.toJsonString());
  }

  Future<User?> getUser() async {
    final userString = await _storage.read(key: 'current_user');
    if (userString != null) {
      return User.fromJsonString(userString);
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: 'current_user');
  }
}
