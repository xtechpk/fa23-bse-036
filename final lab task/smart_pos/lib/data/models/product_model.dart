class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  final double costPrice;    // Industry Standard: To calculate profit later
  final double sellingPrice; // Industry Standard: Price shown to customer
  int stockQuantity;
  final int lowStockLimit;
  final int isSynced;

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    this.stockQuantity = 0,
    this.lowStockLimit = 5,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'low_stock_limit': lowStockLimit,
      'is_synced': isSynced,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      sku: map['sku'],
      name: map['name'],
      category: map['category'],
      costPrice: (map['cost_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      stockQuantity: map['stock_quantity'],
      lowStockLimit: map['low_stock_limit'] ?? 5,
      isSynced: map['is_synced'] ?? 0,
    );
  }
}