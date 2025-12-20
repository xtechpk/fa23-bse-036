// lib/presentation/auth/signup_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/remote/supabase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for Shop & Owner Details
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _ntnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _branchController = TextEditingController();
  
  UserRole _selectedRole = UserRole.servant; // Default for Servant Panel

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final auth = SupabaseAuthService();
      
      // Creating the OOP Profile Object
      final profile = UserProfile(
        id: '', // Will be updated by Supabase UUID
        shopName: _shopNameController.text,
        ntnNumber: _ntnController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        branchName: _branchController.text,
        role: _selectedRole,
      );

      try {
        await auth.signUpWithProfile(profile, _emailController.text, _passController.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created!")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Business")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_shopNameController, "Shop/Business Name"),
              _buildTextField(_ntnController, "NTN Number"),
              _buildTextField(_phoneController, "Phone Number", keyboardType: TextInputType.phone),
              _buildTextField(_addressController, "Business Address"),
              _buildTextField(_branchController, "Branch Name"),
              _buildTextField(_emailController, "Email"),
              _buildTextField(_passController, "Password", obscure: true),
              
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role.name.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: const InputDecoration(labelText: "User Role (Panel Access)"),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignup, 
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Create Professional Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }
}