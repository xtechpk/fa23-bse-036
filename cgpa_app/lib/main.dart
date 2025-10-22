import 'package:flutter/material.dart';

import 'data/services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  // Renamed the root application widget to MyApp as requested.
  runApp(const MyApp());
}

// Renamed the main app widget from CgpaCalculatorApp to MyApp.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Retaining the correct application title
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using the ColorScheme.fromSeed structure, but keeping the theme green-centric
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // Professional Input Styling
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.green.shade50,
        ),
        // Professional Button Styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 15),
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            elevation: 5,
          ),
        ),
      ),
      // AuthWrapper handles initial routing (Login vs. Home)
      home: AuthWrapper(apiService: ApiService()),
    );
  }
}

// Handles routing between authentication and home screens
class AuthWrapper extends StatefulWidget {
  final ApiService apiService;
  const AuthWrapper({super.key, required this.apiService});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Use the provided ApiService instance
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // In a real app, this attempts to validate a stored JWT or session token.
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoading = false;
    });
  }

  void _onAuthChange() {
    setState(() {}); // Force rebuild upon sign in/out
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.apiService.currentUser != null) {
      return HomeScreen(
        authService: widget.apiService,
        onSignOut: _onAuthChange,
      );
    } else {
      return LoginScreen(
          onSignIn: _onAuthChange, authService: widget.apiService);
    }
  }
}
