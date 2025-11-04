import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/auth_service.dart';
import 'package:task_app/app_themes.dart';
import 'package:task_app/theme_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _infoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isInfoLoading = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateInfo() async {
    if (_infoFormKey.currentState!.validate()) {
      setState(() => _isInfoLoading = true);
      try {
        await AuthService().updateUserInfo(
          username: _usernameController.text,
          email: _emailController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Update failed: ${e.toString().replaceFirst("Exception: ", "")}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isInfoLoading = false);
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() => _isPasswordLoading = true);
      try {
        await AuthService().updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!')),
          );
          // Clear fields on success
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Update failed: ${e.toString().replaceFirst("Exception: ", "")}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isPasswordLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Update Profile Info Section ---
            Text('Profile Information',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Form(
              key: _infoFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? 'Please enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _isInfoLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updateInfo,
                          child: const Text('Save Changes'),
                        ),
                ],
              ),
            ),
            const Divider(height: 48),
            // --- Theme Selection Section ---
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildThemeSelector(context),
            const Divider(height: 48),

            // --- Change Password Section ---
            Text('Change Password',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Current Password'),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Current password is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                        labelText: 'Confirm New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isPasswordLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updatePassword,
                          child: const Text('Change Password'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      children: [
        RadioListTile<AppTheme>(
          title: const Text('Default Purple'),
          value: AppTheme.deepPurple,
          groupValue: themeNotifier.currentThemeKey,
          onChanged: (AppTheme? value) {
            if (value != null) {
              themeNotifier.setTheme(value);
            }
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('Ocean Blue Gradient'),
          value: AppTheme.oceanBlue,
          groupValue: themeNotifier.currentThemeKey,
          onChanged: (AppTheme? value) {
            if (value != null) {
              themeNotifier.setTheme(value);
            }
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('Sunset Orange Gradient'),
          value: AppTheme.sunsetOrange,
          groupValue: themeNotifier.currentThemeKey,
          onChanged: (AppTheme? value) {
            if (value != null) {
              themeNotifier.setTheme(value);
            }
          },
        ),
      ],
    );
  }
}
