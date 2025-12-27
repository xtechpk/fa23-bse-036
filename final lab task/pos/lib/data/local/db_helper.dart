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
    String path;
    if (kIsWeb) {
      path = 'smart_pos_pro_v1.db';
    } else {
      path = join(await getDatabasesPath(), 'smart_pos_pro_v1.db');
    }

    return await openDatabase(
      path,
      version: 2, // Incremented version to handle schema changes
      onCreate: (db, version) async {
        // Business Profile Table
        await db.execute('''
          CREATE TABLE profile (
            id TEXT PRIMARY KEY,
            shop_name TEXT,
            ntn_number TEXT,
            phone_number TEXT,
            address TEXT
          )
        ''');
        
        // Products Table (Synchronized with ProductModel)
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            sku TEXT UNIQUE,
            name TEXT,
            category TEXT,
            cost_price REAL,
            selling_price REAL,
            stock_quantity INTEGER DEFAULT 0,
            low_stock_limit INTEGER DEFAULT 5,
            image_url TEXT, 
            is_synced INTEGER DEFAULT 0
          )
        ''');

        // Sales Table (Master)
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            total_amount REAL,
            total_profit REAL,
            customer_name TEXT,
            date TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');

        // Sale Items Table (Details - For detailed receipts)
        await db.execute('''
          CREATE TABLE sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id TEXT,
            product_id TEXT,
            product_name TEXT,
            quantity INTEGER,
            price REAL,
            FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}