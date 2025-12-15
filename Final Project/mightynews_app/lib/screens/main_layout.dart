import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/content_provider.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'editor_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;
  final _screens = const [HomeScreen(), SavedScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    // Fetch data immediately upon login
    final user = context.read<AppProvider>().currentUser;
    if (user != null) {
      context.read<ContentProvider>().fetchBlogs(user.id);
      context.read<ContentProvider>().fetchBookmarks(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AppProvider, bool>((p) => p.isAdmin);

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: "Feed"),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: "Saved"),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: (_index == 0 && isAdmin)
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen())),
            label: const Text("Write"),
            icon: const Icon(Icons.edit),
          )
        : null,
    );
  }
}