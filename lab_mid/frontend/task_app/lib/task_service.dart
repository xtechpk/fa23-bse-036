import 'package:dio/dio.dart';
import 'package:task_app/api_client.dart';
import 'package:task_app/task_model.dart';
import 'package:task_app/secure_storage_service.dart';

class TaskService {
  final ApiClient _apiClient = ApiClient(Dio(), SecureStorageService());

  Future<List<Task>> getTasks() async {
    try {
      final response = await _apiClient.dio.get('tasks');

      List<Task> tasks = (response.data as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
      return tasks;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch tasks.');
    } catch (e) {
      throw Exception('An unknown error occurred while fetching tasks.');
    }
  }

  Future<Task> createTask(
      {required String title,
      String? description,
      int? categoryId,
      String? priority,
      String? dueDateTime}) async {
    try {
      final response = await _apiClient.dio.post('tasks', data: {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'priority': priority,
        'dueDateTime': dueDateTime,
      });
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to create task.');
    }
  }

  Future<Task> updateTask(
      {required int taskId, required bool isCompleted}) async {
    try {
      final response = await _apiClient.dio.put(
        'tasks/$taskId',
        data: {
          'isCompleted': isCompleted,
        },
      );
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to update task.');
    }
  }
}
