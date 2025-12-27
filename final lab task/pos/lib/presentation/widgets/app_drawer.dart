// lib/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart'; // Import the UserRole enum

class AppDrawer extends StatelessWidget {
  final UserRole userRole;

  const AppDrawer({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("Smart POS Menu")),
          // Always visible for all
          ListTile(title: const Text("POS Billing"), onTap: () {}),
          
          // Hidden from 'servant' - visible for Admin/SuperAdmin
          if (userRole != UserRole.servant)
            ListTile(title: const Text("Inventory Management"), onTap: () {}),
          
          // Only visible for Super Admin
          if (userRole == UserRole.superAdmin)
            ListTile(title: const Text("Detailed Reports"), onTap: () {}),
            
          const Divider(),
          // Theme Switcher within the Drawer
          ListTile(
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (val) {
                context.read<ThemeProvider>().toggleTheme(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}