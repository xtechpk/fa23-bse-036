import 'package:flutter/material.dart';
import '../../data/remote/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().signUp(_emailController.text, _passController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created! Please login to set up your profile."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const LoginScreen())
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.app_registration_rounded, size: 60, color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    const Text(
                      "Create POS Account",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const Text(
                      "Start managing your business efficiently",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    _buildInputField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      validator: (v) => (v == null || !v.contains('@')) ? "Enter a valid email" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _passController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) => (v == null || v.length < 6) ? "Minimum 6 characters" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _confirmPassController,
                      label: "Confirm Password",
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      validator: (v) => v != _passController.text ? "Passwords do not match" : null,
                    ),

                    const SizedBox(height: 32),

                    _isLoading 
                      ? const CircularProgressIndicator() 
                      : ElevatedButton(
                          onPressed: _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text("REGISTER BUSINESS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
        suffixIcon: isPassword && toggleVisibility != null
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: toggleVisibility,
            ) 
          : null,
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}