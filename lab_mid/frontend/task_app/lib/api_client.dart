import 'package:dio/dio.dart';
import 'package:task_app/secure_storage_service.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _storageService;

  ApiClient(this._dio, this._storageService) {
    _dio.options.baseUrl =
        'http://localhost:4000/api/'; // Correct IP for Android emulator
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the token from secure storage
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options); // Continue
        },
      ),
    );
  }

  // Getter to access the Dio instance
  Dio get dio => _dio;
}
