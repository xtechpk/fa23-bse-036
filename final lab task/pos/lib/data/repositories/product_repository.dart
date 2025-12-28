import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepository {
  final _dbHelper = DBHelper();

  // --- Category Methods ---
  Future<List<CategoryModel>> fetchAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', category.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Product CRUD Methods ---
  Future<void> addProduct(ProductModel product) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Database Error: $e");
    }
  }

  Future<List<ProductModel>> fetchAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  // Update Product (Full CRUD)
  Future<void> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete Product (Full CRUD)
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}