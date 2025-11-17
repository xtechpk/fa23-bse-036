import 'package:flutter/material.dart';
import 'package:task_app/dashboard_screen.dart';
import 'package:task_app/login_screen.dart';
import 'package:task_app/secure_storage_service.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Use a short delay to avoid a jarring transition on fast devices
    await Future.delayed(const Duration(milliseconds: 500));

    final token = await SecureStorageService().getToken();
    if (!mounted) return;

    if (token != null) {
      // Token exists, navigate to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // No token, navigate to Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth status
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
