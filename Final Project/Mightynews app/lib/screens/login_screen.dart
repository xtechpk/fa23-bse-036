import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.newspaper, size: 60, color: Color(0xFF0F172A)),
              const SizedBox(height: 10),
              const Text("Mighty News Pro", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
              if (auth.error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(auth.error!, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 45, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                onPressed: auth.isLoading ? null : () => auth.login(userCtrl.text, passCtrl.text),
                child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login"),
              )),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Create Account", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              const Text("Admin: admin/admin123", style: TextStyle(fontSize: 10, color: Colors.grey))
            ],
          ),
        ),
      ),
    );
  }
}