import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:task_app/auth_service.dart';
import 'package:task_app/login_screen.dart';
import 'package:task_app/task_model.dart';
import 'package:task_app/task_service.dart';
import 'package:task_app/categories_screen.dart';
import 'package:task_app/create_task_screen.dart';
import 'package:task_app/profile_screen.dart';
import 'package:task_app/create_category_screen.dart';
import 'package:task_app/themed_scaffold.dart';

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

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
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

    return ThemedScaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
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
              child: FaIcon(
                _selectedIndex == 0
                    ? FontAwesomeIcons.listCheck
                    : FontAwesomeIcons.plus,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.listCheck),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tags),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
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
  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await TaskService().getTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
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

  // Public method to allow parent to trigger a refresh
  void fetchTasks() => _fetchTasks();

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = await TaskService()
          .updateTask(taskId: task.id, isCompleted: !task.isCompleted);

      setState(() {
        final index = _tasks!.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks![index] = updatedTask;
        }
      });
    } catch (e) {
      // Optionally show a snackbar error
    }
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
      child: ListView.builder(
        itemCount: _tasks!.length,
        itemBuilder: (context, index) {
          final task = _tasks![index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
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
              subtitle: task.description != null && task.description!.isNotEmpty
                  ? Text(task.description!)
                  : null,
              trailing: task.category != null
                  ? Chip(
                      label: Text(task.category!.name),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    )
                  : null,
              onTap: () {
                // Placeholder for future navigation
              },
            ),
          );
        },
      ),
    );
  }
}
