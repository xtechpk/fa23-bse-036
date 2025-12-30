import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../pos/pos_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../inventory/inventory_screen.dart';
import '../widgets/app_drawer.dart';
import '../../data/models/user_model.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 1; // Default to POS

  final List<Widget> _screens = [
    const DashboardScreen(),
    const POSScreen(),
    const InventoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: Scaffold(
          appBar: AppBar(title: const Text("Smart POS Pro")),
          drawer: AppDrawer(userRole: UserRole.admin),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "POS"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventory"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
        tablet: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Home")),
                NavigationRailDestination(icon: Icon(Icons.shopping_cart), label: Text("POS")),
                NavigationRailDestination(icon: Icon(Icons.inventory), label: Text("Inventory")),
                NavigationRailDestination(icon: Icon(Icons.person), label: Text("Profile")),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
        desktop: Row(
          children: [
            _buildSidebar(),
            const VerticalDivider(width: 1),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: const Center(child: Text("SMART POS PRO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.blueAccent))),
          ),
          const SizedBox(height: 12),
          _sidebarTile(0, Icons.dashboard, "Dashboard"),
          _sidebarTile(1, Icons.shopping_cart, "POS Terminal"),
          _sidebarTile(2, Icons.inventory, "Inventory Management"),
          ListTile(leading: const Icon(Icons.category), title: const Text('Manage Categories'), onTap: () => Navigator.pushNamed(context, '/categories')),
          _sidebarTile(3, Icons.person, "Business Profile"),
        ],
      ),
    );
  }

  Widget _sidebarTile(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.blueAccent : Colors.grey),
      title: Text(title, style: TextStyle(color: _selectedIndex == index ? Colors.blueAccent : Colors.black)),
      selected: _selectedIndex == index,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}