import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../pos/pos_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

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
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: Scaffold(
          appBar: AppBar(title: const Text("Smart POS Pro")),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "POS"),
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
      color: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text("SMART POS PRO", 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.blueAccent)),
            ),
          ),
          _sidebarTile(0, Icons.dashboard, "Dashboard"),
          _sidebarTile(1, Icons.shopping_cart, "POS Terminal"),
          _sidebarTile(2, Icons.person, "Business Profile"),
        ],
      ),
    );
  }

  Widget _sidebarTile(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}