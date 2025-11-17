import 'package:flutter/material.dart';
import 'package:task_app/category_model.dart';
import 'package:task_app/task_model.dart';
import 'package:task_app/task_service.dart';
import 'package:task_app/category_service.dart';
import 'package:task_app/notification_service.dart';

class UpdateTaskScreen extends StatefulWidget {
  final Task task;
  const UpdateTaskScreen({super.key, required this.task});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;

  int? _selectedCategoryId;
  String? _selectedPriority;
  DateTime? _selectedDateTime;
  List<Category>? _categories;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController();

    _selectedCategoryId = widget.task.category?.id;
    _selectedPriority = widget.task.priority;
    _selectedDateTime = widget.task.dueDateTime;

    if (_selectedDateTime != null) {
      _updateDueDateText(_selectedDateTime!);
    }

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      if (!mounted) return;
      final categories = await CategoryService().getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedTask = await TaskService().updateTask(
          taskId: widget.task.id,
          title: _titleController.text,
          description: _descriptionController.text,
          categoryId: _selectedCategoryId,
          priority: _selectedPriority,
          dueDate: _selectedDateTime?.toIso8601String(),
        );

        // Re-schedule the notification with the updated details
        await NotificationService().scheduleNotificationForTask(updatedTask);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully!')),
          );
          Navigator.of(context).pop(true); // Pop with success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update task: ${e.toString().replaceFirst("Exception: ", "")}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _updateDueDateText(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    _dueDateController.text =
        '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
          _updateDueDateText(_selectedDateTime!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date & Time (Optional)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 16),
              if (_categories != null)
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: _categories!
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                hint: const Text('Select Priority (Optional)'),
                items: ['LOW', 'MEDIUM', 'HIGH']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Update Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
