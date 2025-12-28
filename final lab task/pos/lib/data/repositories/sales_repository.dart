// lib/data/repositories/sales_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../local/db_helper.dart';
import '../models/cart_item.dart';

class SalesRepository {
  final _dbHelper = DBHelper();

  // FIX: This method was missing in your error log
  Future<bool> processCheckout({
    required List<CartItem> cart,
    required String customerName,
  }) async {
    final db = await _dbHelper.database;
    final String saleId = const Uuid().v4();
    final String date = DateTime.now().toIso8601String();

    double totalAmount = 0;
    double totalProfit = 0;

    for (var item in cart) {
      totalAmount += item.product.sellingPrice * item.quantity;
      totalProfit += (item.product.sellingPrice - item.product.costPrice) * item.quantity;
    }

    return await db.transaction((txn) async {
      try {
        await txn.insert('sales', {
          'id': saleId,
          'total_amount': totalAmount,
          'total_profit': totalProfit,
          'customer_name': customerName,
          'date': date,
          'is_synced': 0,
        });

        for (var item in cart) {
          await txn.insert('sale_items', {
            'sale_id': saleId,
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.sellingPrice,
          });

          // Stock deduction
          await txn.rawUpdate(
            'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
            [item.quantity, item.product.id],
          );
        }
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchSalesByRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    String startStr = DateTime(start.year, start.month, start.day, 0, 0, 0).toIso8601String();
    String endStr = DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();

    return await db.query(
      'sales',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchSalesHistory() async {
    final db = await _dbHelper.database;
    return await db.query('sales', orderBy: 'date DESC');
  }
}