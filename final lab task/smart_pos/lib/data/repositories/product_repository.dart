import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/db_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _supabase = Supabase.instance.client;
  final _db = DBHelper();

  // Add Product: Saves locally first, then syncs 
  Future<void> addProduct(ProductModel product) async {
    final db = await _db.database;
    
    // 1. Save Locally (Offline Mode Compulsory) 
    await db.insert('products', product.toMap());

    // 2. Auto Sync to Supabase 
    try {
      await _supabase.from('products').insert(product.toMap());
      // Update local flag to synced
      await db.update('products', {'is_synced': 1}, where: 'id = ?', whereArgs: [product.id]);
    } catch (e) {
      print("Offline Mode: Product saved locally only.");
    }
  }

  // Fetch all products for the UI
  Future<List<ProductModel>> getAllProducts() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((item) => ProductModel.fromMap(item)).toList();
  }
}