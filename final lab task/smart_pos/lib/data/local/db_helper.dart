import 'package:flutter/foundation.dart'; // For kIsWeb detection
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
      // Web doesn't use absolute paths; it uses a virtual name
      path = 'smart_pos_pro_v1.db';
    } else {
      // Mobile (APK) uses actual device storage paths
      path = join(await getDatabasesPath(), 'smart_pos_pro_v1.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table 1: Business Profile (Shop Info)
        await db.execute('''
          CREATE TABLE profile (
            id TEXT PRIMARY KEY,
            shop_name TEXT,
            ntn_number TEXT,
            phone_number TEXT,
            address TEXT
          )
        ''');
        
        // Table 2: Products (Pro-Level Inventory)
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
            is_synced INTEGER DEFAULT 0
          )
        ''');

        // Table 3: Sales (For Commit 3 - Billing)
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            total_amount REAL,
            customer_name TEXT,
            date TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
}