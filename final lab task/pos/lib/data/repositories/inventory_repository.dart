import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/product_model.dart';

class InventoryRepository {
  final _supabase = Supabase.instance.client;
  final _db = DBHelper();

  // Task 3: Add/Edit Product (Saves Offline first, then Syncs)
  Future<void> saveProduct(ProductModel product) async {
    final db = await _db.database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    try {
      await _supabase.from('products').upsert(product.toMap());
      await db.update('products', {'is_synced': 1}, where: 'id = ?', whereArgs: [product.id]);
    } catch (e) {
      print("Offline: Data safe in mobile storage.");
    }
  }

  // Task 4: Stock Adjustment (Industry Pro Level)
  Future<void> updateStock(String id, int newQuantity) async {
    final db = await _db.database;
    await db.update('products', {'stock_quantity': newQuantity, 'is_synced': 0}, where: 'id = ?', whereArgs: [id]);
    
    try {
      await _supabase.from('products').update({'stock_quantity': newQuantity}).eq('id', id);
      await db.update('products', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }

  Future<List<ProductModel>> fetchAll() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }
}