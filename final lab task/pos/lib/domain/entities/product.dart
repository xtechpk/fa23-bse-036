// lib/domain/entities/product.dart

class Product {
  final String id;
  final String sku;
  final String name;
  final String category;
  final double price;
  final double cost;
  int stockQuantity;
  final int lowStockThreshold;
  final bool isSynced; // For Offline Sync Logic

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.cost,
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.isSynced = false,
  });

  // Factory to create from SQLite/Supabase Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      sku: map['sku'],
      name: map['name'],
      category: map['category'],
      price: (map['selling_price'] as num).toDouble(),
      cost: (map['cost_price'] as num).toDouble(),
      stockQuantity: map['stock_quantity'] ?? 0,
      lowStockThreshold: map['low_stock_threshold'] ?? 5,
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'selling_price': price,
      'cost_price': cost,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'is_synced': isSynced ? 1 : 0,
    };
  }
}