// lib/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/models/user_model.dart'; // Import the UserRole enum

class AppDrawer extends StatelessWidget {
  final UserRole userRole;

  const AppDrawer({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.9), Theme.of(context).colorScheme.primary])),
            child: const Center(child: Text("Smart POS Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          // Always visible for all
          ListTile(title: const Text("POS Billing"), onTap: () {}),
          
          // Hidden from 'servant' - visible for Admin/SuperAdmin
          if (userRole != UserRole.servant) ...[
            ListTile(title: const Text("Inventory Management"), onTap: () {}),
            ListTile(title: const Text("Manage Categories"), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/categories'); }),
          ],
          
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