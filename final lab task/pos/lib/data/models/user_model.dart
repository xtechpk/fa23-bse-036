// lib/data/models/user_profile.dart

enum UserRole { superAdmin, admin, servant }

class UserProfile {
  // Private fields for Encapsulation
  final String _id;
  final String _shopName;
  final String _ntnNumber;
  final String _phoneNumber;
  final String _address;
  final String _branchName;
  final UserRole _role;

  UserProfile({
    required String id,
    required String shopName,
    required String ntnNumber,
    required String phoneNumber,
    required String address,
    required String branchName,
    required UserRole role,
  })  : _id = id,
        _shopName = shopName,
        _ntnNumber = ntnNumber,
        _phoneNumber = phoneNumber,
        _address = address,
        _branchName = branchName,
        _role = role;

  // Public Getters
  String get id => _id;
  String get shopName => _shopName;
  UserRole get role => _role;

  // Convert to Map for Supabase/PostgreSQL
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'shop_name': _shopName,
      'ntn_number': _ntnNumber,
      'phone_number': _phoneNumber,
      'address': _address,
      'branch_name': _branchName,
      'role': _role.name, // Stores as string: 'superAdmin', etc.
    };
  }
}