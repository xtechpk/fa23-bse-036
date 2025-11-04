import 'package:task_app/category_model.dart';

class Task {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDateTime;
  final String? priority;
  final List<Subtask> subtasks;
  final Category? category;
  // Add other fields like category, repetitions, etc. as needed

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDateTime,
    this.priority,
    this.category,
    required this.subtasks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      dueDateTime: json['dueDateTime'] != null
          ? DateTime.parse(json['dueDateTime'])
          : null,
      priority: json['priority'],
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((subtaskJson) => Subtask.fromJson(subtaskJson))
              .toList() ??
          [],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}

class Subtask {
  final int id;
  final String name;
  final bool isCompleted;

  Subtask({
    required this.id,
    required this.name,
    required this.isCompleted,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

// You can also create a Category model if you plan to use it
// class Category { ... }