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

  factory Task.fromJson(Map<String, dynamic> json,
      {List<Subtask>? existingSubtasks}) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      dueDateTime:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'],
      subtasks: existingSubtasks ??
          ((json['subtasks'] as List<dynamic>?)
                  ?.map((subtaskJson) => Subtask.fromJson(subtaskJson))
                  .toList() ??
              []),
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDateTime?.toIso8601String(),
      'priority': priority,
      'category': category?.toJson(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
    };
  }
}

class Subtask {
  final int id;
  final String name;
  final bool isCompleted;
  final DateTime? dueDateTime;

  Subtask({
    required this.id,
    required this.name,
    required this.isCompleted,
    this.dueDateTime,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      dueDateTime:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'dueDate': dueDateTime?.toIso8601String(),
    };
  }
}

// You can also create a Category model if you plan to use it
// class Category { ... }