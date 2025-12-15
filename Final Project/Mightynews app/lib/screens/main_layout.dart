import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'support_screen.dart';
import 'editor_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tabs = [
      const HomeScreen(),
      _buildProfile(context, auth),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: (_index == 0 && auth.isAdmin)
        ? FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen())),
          )
        : null,
    );
  }

  Widget _buildProfile(BuildContext context, AuthProvider auth) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 15),
          Center(child: Text(auth.user?.username.toUpperCase() ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Center(child: Text(auth.isAdmin ? "Admin Access" : "Standard User", style: const TextStyle(color: Colors.blue))),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Support & Help"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            trailing: const Text("v2.1.0 Pro"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => auth.logout(),
          ),
        ],
      ),
    );
  }
}