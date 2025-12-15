import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final user = app.currentUser!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 15),
            Center(child: Text(user.username.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Center(child: Text(user.role.toUpperCase(), style: const TextStyle(color: Colors.blue, letterSpacing: 1.5))),
            const SizedBox(height: 40),
            
            // Support Ticket Feature
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text("Support System"),
              subtitle: const Text("Report bugs or request features"),
              onTap: () => _showSupportDialog(context),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("App Version"),
              trailing: Text("v3.0.0 Pro"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => app.logout(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final sub = TextEditingController();
    final msg = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Contact Support"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sub, decoration: const InputDecoration(labelText: "Subject")),
            TextField(controller: msg, decoration: const InputDecoration(labelText: "Message")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().submitTicket(sub.text, msg.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket Submitted")));
            }, 
            child: const Text("Submit")
          )
        ],
      )
    );
  }
}