// 3.1 SCREENS (lib/screens/login_screen.dart)
// ---------------------

import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

// ---------------------
// 3.1 SCREENS (lib/screens/login_screen.dart)
// ---------------------

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  // Now requires ApiService
  final ApiService authService;

  const LoginScreen(
      {super.key, required this.onSignIn, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  void _signIn() async {
    // Validate form before attempting sign in
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await widget.authService
          .signIn(_emailController.text.trim(), _passwordController.text);
      widget.onSignIn();
    } catch (e) {
      setState(() {
        // Display the specific error message from the API response
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (_formKey.currentState?.validate() ?? false) {
                          _signIn();
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ForgotPasswordScreen(authService: widget.authService),
                  ),
                ),
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(
                        onSignUp: widget.onSignIn,
                        authService: widget.authService),
                  ),
                ),
                child: const Text('Create New Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
