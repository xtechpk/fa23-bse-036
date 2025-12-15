import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  void _submit() async {
    setState(() => loading = true);
    final auth = context.read<AppProvider>();
    bool success;
    
    if (isLogin) {
      success = await auth.login(userCtrl.text, passCtrl.text);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
      }
    } else {
      success = await auth.register(userCtrl.text, passCtrl.text);
      if (success && mounted) {
        setState(() => isLogin = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Login now.")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username taken or Error")));
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Mighty News", style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 5),
                Text(isLogin ? "Welcome Back" : "Join the Community", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 15),
                TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    onPressed: loading ? null : _submit,
                    child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(isLogin ? "LOGIN" : "REGISTER"),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? "New here? Register" : "Have an account? Login"),
                ),
                const SizedBox(height: 10),
                const Text("Admin: admin / admin123", style: TextStyle(fontSize: 12, color: Colors.grey))
              ],
            ),
          ),
        ),
      ),
    );
  }
}