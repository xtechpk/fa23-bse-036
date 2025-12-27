import 'package:uuid/uuid.dart';
import '../local/db_helper.dart';
import '../models/cart_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class SalesRepository {
  final _dbHelper = DBHelper();

  Future<bool> processCheckout({
    required List<CartItem> cart,
    required String customerName,
  }) async {
    final db = await _dbHelper.database;
    
    // Generate a unique ID for this transaction
    final String saleId = const Uuid().v4();
    final String date = DateTime.now().toIso8601String();

    double totalAmount = 0;
    double totalProfit = 0;

    // Calculate totals for the master record
    for (var item in cart) {
      totalAmount += item.product.sellingPrice * item.quantity;
      // Profit = (Selling Price - Cost Price) * Quantity
      totalProfit += (item.product.sellingPrice - item.product.costPrice) * item.quantity;
    }

    // Use a Transaction to ensure "All or Nothing" (Atomicity)
    return await db.transaction((txn) async {
      try {
        // 1. Insert into 'sales' table (Master)
        await txn.insert('sales', {
          'id': saleId,
          'total_amount': totalAmount,
          'total_profit': totalProfit,
          'customer_name': customerName,
          'date': date,
          'is_synced': 0,
        });

        // 2. Insert each item into 'sale_items' table & update stock
        for (var item in cart) {
          await txn.insert('sale_items', {
            'sale_id': saleId,
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.sellingPrice,
          });

          // 3. Deduct stock quantity in the products table
          await txn.rawUpdate(
            'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
            [item.quantity, item.product.id],
          );
        }
        
        debugPrint("Checkout successful for Sale ID: $saleId");
        return true;
      } catch (e) {
        debugPrint("Database Transaction Error: $e");
        return false;
      }
    });
  }
}