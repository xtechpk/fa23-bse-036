import 'package:flutter/foundation.dart'; // REQUIRED FOR debugPrint
import '../../data/models/product_model.dart';
import '../../data/local/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('products');

      return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint("Repository Error: $e"); // Now this will work
      return [];
    }
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}