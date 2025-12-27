// lib/data/models/user_profile.dart

class UserProfile {
  final String id;
  String shopName;
  String ntnNumber;
  String phoneNumber;
  String address;

  UserProfile({
    required this.id,
    this.shopName = "",
    this.ntnNumber = "",
    this.phoneNumber = "",
    this.address = "",
  });

  // For Supabase & SQLite integration
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'ntn_number': ntnNumber,
      'phone_number': phoneNumber,
      'address': address,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      shopName: map['shop_name'] ?? "",
      ntnNumber: map['ntn_number'] ?? "",
      phoneNumber: map['phone_number'] ?? "",
      address: map['address'] ?? "",
    );
  }
}