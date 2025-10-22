// ---------------------
// 3.4 SCREENS (lib/screens/home_screen.dart)
// ---------------------

import '../data/services/api_service.dart';
import 'cgpa_calculator_screen.dart';
import 'profile_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final ApiService authService;
  final VoidCallback onSignOut;

  const HomeScreen(
      {super.key, required this.authService, required this.onSignOut});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _updateUser() {
    setState(() {}); // Force update to reflect profile changes
  }

  List<Widget> _getScreens() {
    // Note: widget.authService.currentUser will never be null here due to AuthWrapper guard.
    return [
      CgpaCalculatorScreen(
        user: widget.authService.currentUser!,
        authService: widget.authService,
        onUpdate: _updateUser,
      ),
      ProfileScreen(
        authService: widget.authService,
        onUpdate: _updateUser,
        onSignOut: widget.onSignOut,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name.split(' ').first}'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'CGPA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
