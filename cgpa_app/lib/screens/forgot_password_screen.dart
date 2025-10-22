import 'package:flutter/material.dart';
import '../data/services/api_service.dart';

// ---------------------
// 3.3 SCREENS (lib/screens/forgot_password_screen.dart)
// ---------------------

class ForgotPasswordScreen extends StatefulWidget {
  final ApiService authService;
  const ForgotPasswordScreen({super.key, required this.authService});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  void _forgotPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });
    try {
      await widget.authService.forgotPassword(_emailController.text.trim());
      setState(() {
        _message = 'Password reset link sent to your email!';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isError = true;
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Reset Your Password',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Enter Email', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 30),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    _message!,
                    style: TextStyle(
                        color: _isError ? Colors.red : Colors.green.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _forgotPassword,
                      child: const Text('Send Reset Link'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
