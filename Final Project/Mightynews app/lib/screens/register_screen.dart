import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Join Us")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "New Username")),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<AuthProvider>().register(userCtrl.text, passCtrl.text);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success! Please Login.")));
                  Navigator.pop(context);
                }
              },
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}