import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_getTitle()),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text("Business Owner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text("owner@smartpos.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard_rounded, "Dashboard"),
            _buildDrawerItem(1, Icons.inventory_2_rounded, "Inventory"),
            _buildDrawerItem(2, Icons.business_center_rounded, "Profile Settings"),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pop(context), // Implement actual logout later
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return "Market Dashboard";
      case 1: return "Inventory Management";
      case 2: return "Business Profile";
      default: return "Smart POS";
    }
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}