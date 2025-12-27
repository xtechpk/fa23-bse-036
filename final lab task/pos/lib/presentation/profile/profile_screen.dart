import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/local/db_helper.dart';
import '../../core/utils/responsive.dart';

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
        setState(() => _isLoading = false);
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
        final localDB = await _db.database;
        await localDB.insert('profile', profileData, conflictAlgorithm: ConflictAlgorithm.replace);
        await Supabase.instance.client.from('profiles').upsert(profileData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully"), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saved Offline Successfully"), backgroundColor: Colors.orange)
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
      appBar: AppBar(
        title: const Text("Business Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildResponsiveFormLayout(),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.storefront_rounded, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _shopController.text.isEmpty ? "Your Shop Name" : _shopController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text("POS Verified Merchant", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildResponsiveFormLayout() {
    bool isWide = MediaQuery.of(context).size.width > 750;
    
    return Column(
      children: [
        if (isWide) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSectionCard("Basic Identity", [
                _buildInput(_shopController, "Legal Shop Name", Icons.store_rounded),
                _buildInput(_ntnController, "NTN / Tax Number", Icons.badge_rounded),
              ])),
              const SizedBox(width: 24),
              Expanded(child: _buildSectionCard("Contact Details", [
                _buildInput(_phoneController, "Support Phone", Icons.phone_rounded),
                _buildInput(_addressController, "Business Address", Icons.location_on_rounded),
              ])),
            ],
          )
        ] else ...[
          _buildSectionCard("Business Information", [
            _buildInput(_shopController, "Legal Shop Name", Icons.store_rounded),
            _buildInput(_ntnController, "NTN / Tax Number", Icons.badge_rounded),
            _buildInput(_phoneController, "Support Phone", Icons.phone_rounded),
            _buildInput(_addressController, "Business Address", Icons.location_on_rounded),
          ]),
        ],
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: const Color(0xFFF1F3F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text("SAVE & SYNC CLOUD", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }
}