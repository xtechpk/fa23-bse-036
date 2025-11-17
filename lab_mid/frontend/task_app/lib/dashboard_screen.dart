import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/auth_service.dart';
import 'package:task_app/user_model.dart';
import 'package:task_app/login_screen.dart';
import 'package:task_app/task_model.dart';
import 'package:task_app/task_service.dart';
import 'package:task_app/categories_screen.dart';
import 'package:task_app/create_task_screen.dart';
import 'package:task_app/profile_screen.dart';
import 'package:task_app/create_category_screen.dart';
import 'package:task_app/update_task_screen.dart';
import 'package:task_app/themed_scaffold.dart';
import 'package:task_app/app_themes.dart';
import 'package:task_app/theme_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  // Renaming to MainScreen would be a good next step, but for now we modify this.

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar
  final GlobalKey<_TasksViewState> _tasksViewKey = GlobalKey<_TasksViewState>();
  final GlobalKey<CategoriesScreenState> _categoriesScreenKey =
      GlobalKey<CategoriesScreenState>();

  User? _currentUser;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _widgetOptions = <Widget>[
      TasksView(key: _tasksViewKey),
      CategoriesScreen(
        key: _categoriesScreenKey,
        // Pass a function to allow the modal to trigger a refresh
        onCategoryCreated: () =>
            _categoriesScreenKey.currentState?.refreshCategories(),
      ),
      const ProfileScreen(),
    ];
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['My Tasks', 'Categories', 'Profile'];
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return ThemedScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_selectedIndex]),
            if (_currentUser?.username != null)
              Text(
                'Welcome, ${_currentUser!.username}!',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          PopupMenuButton<AppTheme>(
            onSelected: (AppTheme theme) {
              themeNotifier.setTheme(theme);
            },
            icon: const Icon(Icons.color_lens),
            tooltip: 'Change Theme',
            itemBuilder: (BuildContext context) => <PopupMenuEntry<AppTheme>>[
              const PopupMenuItem<AppTheme>(
                value: AppTheme.deepPurple,
                child: Text('Default Purple'),
              ),
              const PopupMenuItem<AppTheme>(
                value: AppTheme.oceanBlue,
                child: Text('Ocean Blue'),
              ),
              const PopupMenuItem<AppTheme>(
                value: AppTheme.sunsetOrange,
                child: Text('Sunset Orange'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex <
              2 // Hide FAB on Profile screen (index 2)
          ? FloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 0) {
                  // On Tasks screen, navigate to Create Task
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                  );
                  if (result == true) {
                    _tasksViewKey.currentState?.fetchTasks();
                  }
                } else if (_selectedIndex == 1) {
                  // On Categories screen, open modal to create category
                  _showCreateCategoryModal(context);
                }
              },
              tooltip: _selectedIndex == 0 ? 'Add Task' : 'Add Category',
              child: Icon(
                  _selectedIndex == 0 ? Icons.playlist_add_check : Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showCreateCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard to not cover the sheet
      builder: (BuildContext context) {
        // Using a Padding to avoid the keyboard
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: CreateCategoryScreen(
            onCategoryCreated: () {
              // When modal closes, refresh the categories list
              _categoriesScreenKey.currentState?.refreshCategories();
            },
          ),
        );
      },
    );
  }
}

// Extracted the original body of the dashboard into its own widget for clarity
class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<Task>? _tasks;
  String? _error;
  bool _isLoading = true;
  final Map<int, TextEditingController> _subtaskControllers = {};
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_filterTasks);
  }

  Future<void> _fetchTasks() async {
    // Clear old controllers
    for (var controller in _subtaskControllers.values) {
      controller.dispose();
    }
    _subtaskControllers.clear();
    try {
      final tasks = await TaskService().getTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _filteredTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredTasks = _tasks ?? []);
      return;
    }
    setState(() {
      _filteredTasks = _tasks?.where((task) {
            final titleMatch = task.title.toLowerCase().contains(query);
            final descriptionMatch =
                task.description?.toLowerCase().contains(query) ?? false;
            return titleMatch || descriptionMatch;
          }).toList() ??
          [];
    });
  }

  // Public method to allow parent to trigger a refresh
  void fetchTasks() => _fetchTasks();

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = await TaskService()
          .updateTask(taskId: task.id, isCompleted: !task.isCompleted);

      setState(() {
        final index = _tasks!.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks![index] = Task.fromJson(updatedTask.toJson(),
              existingSubtasks: task.subtasks);
          // Also update the filtered list
          _filterTasks();
        }
      });
    } catch (e) {
      // Optionally show a snackbar error
    }
  }

  Future<void> _deleteTask(Task task) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            Text('Are you sure you want to delete the task "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TaskService().deleteTask(taskId: task.id);
        setState(() {
          _tasks!.removeWhere((t) => t.id == task.id);
          _filteredTasks.removeWhere((t) => t.id == task.id);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to delete task: ${e.toString().replaceFirst("Exception: ", "")}')));
        }
      }
    }
  }

  Future<void> _createSubtask(Task task) async {
    final controller = _subtaskControllers[task.id];
    if (controller == null || controller.text.isEmpty) return;

    try {
      final newSubtask = await TaskService()
          .createSubtask(taskId: task.id, name: controller.text, dueDate: null);
      setState(() {
        task.subtasks.add(newSubtask);
        controller.clear();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleSubtaskCompletion(Task task, Subtask subtask) async {
    try {
      final updatedSubtask = await TaskService().updateSubtask(
        taskId: task.id,
        subtaskId: subtask.id,
        isCompleted: !subtask.isCompleted,
      );
      setState(() {
        final subtaskIndex =
            task.subtasks.indexWhere((s) => s.id == subtask.id);
        if (subtaskIndex != -1) {
          task.subtasks[subtaskIndex] = updatedSubtask;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteSubtask(Task task, Subtask subtask) async {
    try {
      await TaskService().deleteSubtask(taskId: task.id, subtaskId: subtask.id);
      setState(() {
        task.subtasks.removeWhere((s) => s.id == subtask.id);
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateSubtaskDueDate(Task task, Subtask subtask) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: subtask.dueDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      try {
        final updatedSubtask = await TaskService().updateSubtask(
          taskId: task.id,
          subtaskId: subtask.id,
          dueDate: pickedDate.toIso8601String(),
        );
        setState(() {
          final subtaskIndex =
              task.subtasks.indexWhere((s) => s.id == subtask.id);
          if (subtaskIndex != -1) {
            task.subtasks[subtaskIndex] = updatedSubtask;
          }
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  void _navigateToUpdateScreen(Task task) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => UpdateTaskScreen(task: task),
      ),
    );
    if (result == true) {
      fetchTasks(); // Refresh the list if the task was updated
    }
  }

  @override
  void dispose() {
    _subtaskControllers.forEach((_, controller) => controller.dispose());
    _searchController.removeListener(_filterTasks);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_tasks == null || _tasks!.isEmpty) {
      return const Center(child: Text('No tasks found.'));
    }

    return RefreshIndicator(
        onRefresh: _fetchTasks,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Tasks',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = _filteredTasks[index];
                  _subtaskControllers.putIfAbsent(
                      task.id, () => TextEditingController());
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) => _toggleTaskCompletion(task),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: task.description != null &&
                              task.description!.isNotEmpty
                          ? Text(task.description!,
                              maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.category != null)
                            Chip(
                              label: Text(task.category!.name,
                                  style: const TextStyle(fontSize: 12)),
                              padding: const EdgeInsets.all(4),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteTask(task),
                          ),
                        ],
                      ),
                      onExpansionChanged: (isExpanding) {
                        if (!isExpanding) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              ...task.subtasks.map((subtask) {
                                return ListTile(
                                  leading: Checkbox(
                                    value: subtask.isCompleted,
                                    onChanged: (value) =>
                                        _toggleSubtaskCompletion(task, subtask),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(subtask.name,
                                          style: TextStyle(
                                              decoration: subtask.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none)),
                                      if (subtask.dueDateTime != null)
                                        Text(
                                          'Due: ${subtask.dueDateTime!.toLocal().toString().substring(0, 10)}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.calendar_today,
                                            size: 18),
                                        onPressed: () => _updateSubtaskDueDate(
                                            task, subtask),
                                      ),
                                      IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 20),
                                          onPressed: () =>
                                              _deleteSubtask(task, subtask)),
                                    ],
                                  ),
                                );
                              }),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _subtaskControllers[task.id],
                                      decoration: const InputDecoration(
                                        hintText: 'Add a new subtask...',
                                        isDense: true,
                                      ),
                                      onSubmitted: (_) => _createSubtask(task),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _createSubtask(task),
                                  ),
                                ],
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit_note),
                                title: const Text('Edit Task Details'),
                                onTap: () => _navigateToUpdateScreen(task),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
