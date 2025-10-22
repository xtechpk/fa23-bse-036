import 'package:flutter/material.dart';

import '../data/services/api_service.dart';

// Profile screen: shows user info and allows updating the user's name
class ProfileScreen extends StatefulWidget {
  final ApiService authService;
  final VoidCallback onUpdate;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.authService,
    required this.onUpdate,
    required this.onSignOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.authService.currentUser!.name);
    _emailController =
        TextEditingController(text: widget.authService.currentUser!.email);
  }

  void _updateProfile() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    try {
      await widget.authService.updateProfile(_nameController.text.trim());
      setState(() {
        _message = 'Profile updated successfully!';
      });
      widget.onUpdate();
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

  Future<void> _updateEmail() async {
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      setState(() {
        _message = 'Please enter a valid email.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });
    try {
      await widget.authService.updateEmail(_emailController.text.trim());
      setState(() {
        _message = 'Email updated successfully!';
      });
      widget.onUpdate();
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

  Future<void> _updatePassword() async {
    final newPwd = _passwordController.text;
    if (newPwd.isEmpty || newPwd.length < 3) {
      setState(() {
        _message = 'Password must be at least 3 characters.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });
    try {
      await widget.authService.updatePassword(newPwd);
      setState(() {
        _message = 'Password updated successfully!';
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

  void _signOut() async {
    await widget.authService.signOut();
    widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Email: ${user.email}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (user.cumulativeGpa != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Saved CGPA: ${user.cumulativeGpa!.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const Divider(height: 40),
          Text(
            'Update Profile',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700),
          ),
          const SizedBox(height: 30),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter valid email'
                      : null,
                ),
                const SizedBox(height: 12),
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
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _updateProfile();
                                    }
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text('Update Name'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _updateEmail,
                                  icon: const Icon(Icons.email),
                                  label: const Text('Update Email'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'New Password',
                                prefixIcon: Icon(Icons.lock_outline)),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: _updatePassword,
                              child: const Text('Update Password')),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sign Out',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
