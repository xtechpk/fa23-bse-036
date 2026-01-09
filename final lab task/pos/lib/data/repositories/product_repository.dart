import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';

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

  Future<void> updateCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // --- Sales & Returns ---

  Future<void> updateStock(String productId, int quantityChange) async {
    // quantityChange: negative for sale, positive for return
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?',
      [quantityChange, productId],
    );
  }

  Future<void> saveOrder(OrderModel order) async {
    final db = await _dbHelper.database;
    // Ensure table exists (simple check)
    await db.execute(
      'CREATE TABLE IF NOT EXISTS orders (id TEXT PRIMARY KEY, date TEXT, total REAL, payment_type TEXT, items TEXT)'
    );
    await db.insert('orders', order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OrderModel>> fetchAllOrders() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('orders', orderBy: "date DESC");
      return maps.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      // Table might not exist yet
      return [];
    }
  }
}