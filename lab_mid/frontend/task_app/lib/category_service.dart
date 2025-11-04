import 'package:dio/dio.dart';
import 'package:task_app/api_client.dart';
import 'package:task_app/category_model.dart';
import 'package:task_app/secure_storage_service.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient(Dio(), SecureStorageService());

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('categories');
      List<Category> categories = (response.data as List)
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();
      return categories;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch categories.');
    } catch (e) {
      throw Exception('An unknown error occurred while fetching categories.');
    }
  }

  Future<Category> createCategory(
      {required String name, String? description}) async {
    try {
      final response = await _apiClient.dio.post('categories', data: {
        'name': name,
        'description': description,
      });
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['error'] ?? 'Failed to create category.');
    }
  }

  Future<Category> updateCategory(
      {required int id, required String name, String? description}) async {
    try {
      final response = await _apiClient.dio.put('categories/$id', data: {
        'name': name,
        'description': description,
      });
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['error'] ?? 'Failed to update category.');
    }
  }

  Future<void> deleteCategory({required int id}) async {
    try {
      await _apiClient.dio.delete('categories/$id');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      // Handle 204 No Content response
      if (e.response?.statusCode == 204) {
        return; // Deletion was successful
      }
      throw Exception(
          e.response?.data['error'] ?? 'Failed to delete category.');
    } catch (e) {
      throw Exception('An unknown error occurred while deleting category.');
    }
  }
}
