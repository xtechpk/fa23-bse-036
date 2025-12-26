import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart'; // <--- THIS WAS MISSING
import '../../data/local/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopController = TextEditingController();
  final _ntnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _db = DBHelper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  // Pro Feature: Load existing data from SQLite if available
  void _loadExistingData() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('profile', limit: 1);
    if (maps.isNotEmpty) {
      setState(() {
        _shopController.text = maps.first['shop_name'] ?? '';
        _ntnController.text = maps.first['ntn_number'] ?? '';
        _phoneController.text = maps.first['phone_number'] ?? '';
        _addressController.text = maps.first['address'] ?? '';
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No User Found")));
        return;
      }

      final profileData = {
        'id': user.id,
        'shop_name': _shopController.text,
        'ntn_number': _ntnController.text,
        'phone_number': _phoneController.text,
        'address': _addressController.text,
      };

      try {
        // 1. SAVE LOCALLY (SQLite) - This satisfies the "Offline Mode" requirement
        final localDB = await _db.database;
        await localDB.insert(
          'profile', 
          profileData, 
          conflictAlgorithm: ConflictAlgorithm.replace // Now defined thanks to import
        );

        // 2. SYNC ONLINE (Supabase) - This satisfies the "Online Mode" requirement
        await Supabase.instance.client.from('profiles').upsert(profileData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Synced Online!"), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        // If sync fails, the data is still saved in SQLite on the mobile
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saved Offline. Auto-sync will retry later."), backgroundColor: Colors.orange)
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
      appBar: AppBar(title: const Text("Business Profile Setup")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInput(_shopController, "Shop Name", Icons.store),
                  _buildInput(_ntnController, "NTN Number", Icons.badge),
                  _buildInput(_phoneController, "Business Phone", Icons.phone),
                  _buildInput(_addressController, "Shop Address", Icons.location_on),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Save & Sync Profile"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label, 
          prefixIcon: Icon(icon), 
          border: const OutlineInputBorder()
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}