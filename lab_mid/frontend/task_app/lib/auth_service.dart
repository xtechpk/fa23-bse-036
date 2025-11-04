import 'package:dio/dio.dart';
import 'package:task_app/api_client.dart';
import 'package:task_app/user_model.dart';
import 'package:task_app/secure_storage_service.dart';

class AuthService {
  // Initialize dependencies directly. For larger apps, consider a service locator like get_it.
  final ApiClient _apiClient = ApiClient(Dio(), SecureStorageService());
  final SecureStorageService _storageService = SecureStorageService();

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _apiClient.dio.post('auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      // Re-throw a more user-friendly error message
      throw Exception(
          e.response?.data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);

      // Save both token and user data
      await _storageService.saveToken(token);
      await _storageService.saveUser(user);
    } on DioException catch (e) {
      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.dio.post('auth/forgot-password', data: {
        'email': email,
      });
      // The backend will always return a success-like message to prevent email enumeration.
    } on DioException catch (e) {
      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _apiClient.dio.post('auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      // Return the resetToken on success
      return response.data['resetToken'];
    } on DioException catch (e) {
      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<void> resetPassword(
      {required String resetToken, required String newPassword}) async {
    try {
      await _apiClient.dio.post('auth/reset-password', data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<void> logout() async {
    // The primary action is deleting the token from local storage.
    await _storageService.deleteUser();
    await _storageService.deleteToken();
  }

  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  Future<void> updateUserInfo({String? username, String? email}) async {
    try {
      final Map<String, dynamic> data = {};
      if (username != null && username.isNotEmpty) data['username'] = username;
      if (email != null && email.isNotEmpty) data['email'] = email;

      if (data.isEmpty) return; // Nothing to update

      final response = await _apiClient.dio.put('auth/update-info', data: data);

      // Update the stored user
      final updatedUser = User.fromJson(response.data['user']);
      await _storageService.saveUser(updatedUser);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update profile.');
    }
  }

  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      await _apiClient.dio.put('auth/update-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Could not connect to the server. Please check your network connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update password.');
    }
  }
}
