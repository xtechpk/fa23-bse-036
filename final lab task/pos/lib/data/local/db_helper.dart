import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;
  DBHelper._internal();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = kIsWeb ? 'smart_pos_v6.db' : join(await getDatabasesPath(), 'smart_pos_v6.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // 1. Categories
      await db.execute('CREATE TABLE categories (id TEXT PRIMARY KEY, name TEXT UNIQUE)');
      
      // 2. Products
      await db.execute('''CREATE TABLE products (
        id TEXT PRIMARY KEY, sku TEXT, name TEXT, category TEXT,
        cost_price REAL, selling_price REAL, stock_quantity INTEGER,
        low_stock_limit INTEGER, image_url TEXT, is_synced INTEGER)''');
      
      // 3. Sales Master
      await db.execute('''CREATE TABLE sales (
        id TEXT PRIMARY KEY, total_amount REAL, total_profit REAL,
        customer_name TEXT, date TEXT, is_synced INTEGER DEFAULT 0)''');

      // 4. Sale Items
      await db.execute('''CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id TEXT, product_id TEXT,
        product_name TEXT, quantity INTEGER, price REAL)''');
    });
  }
}