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
      String? dueDate}) async {
    try {
      final response = await _apiClient.dio.post('tasks', data: {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'priority': priority,
        'dueDate': dueDate,
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
      {required int taskId,
      String? title,
      String? description,
      bool? isCompleted,
      int? categoryId,
      String? priority,
      String? dueDate}) async {
    try {
      final response = await _apiClient.dio.put(
        'tasks/$taskId',
        data: {
          'title': title,
          'description': description,
          'isCompleted': isCompleted,
          'categoryId': categoryId,
          'priority': priority,
          'dueDate': dueDate,
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

  Future<void> deleteTask({required int taskId}) async {
    try {
      await _apiClient.dio.delete('tasks/$taskId');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to delete task.');
    }
  }

  // --- Subtask Methods ---

  Future<Subtask> createSubtask(
      {required int taskId, required String name, String? dueDate}) async {
    try {
      final response =
          await _apiClient.dio.post('tasks/$taskId/subtasks', data: {
        'name': name,
        'dueDate': dueDate,
      });
      return Subtask.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to create subtask.');
    }
  }

  Future<Subtask> updateSubtask(
      {required int taskId,
      required int subtaskId,
      String? name,
      bool? isCompleted,
      String? dueDate}) async {
    try {
      final response =
          await _apiClient.dio.put('tasks/$taskId/subtasks/$subtaskId', data: {
        'name': name,
        'isCompleted': isCompleted,
        'dueDate': dueDate,
      });
      return Subtask.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update subtask.');
    }
  }

  Future<void> deleteSubtask(
      {required int taskId, required int subtaskId}) async {
    try {
      await _apiClient.dio.delete('tasks/$taskId/subtasks/$subtaskId');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to delete subtask.');
    }
  }
}
