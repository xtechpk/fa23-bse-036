class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  final double costPrice;    
  final double sellingPrice; 
  int stockQuantity;
  final int lowStockLimit;
  final int isSynced;
  final String? imageUrl; // NEW: Added for image support

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
    this.imageUrl, // NEW: Added to constructor
  });

  // NEW: copyWith method for easier state management (e.g., deducting stock)
  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? lowStockLimit,
    int? isSynced,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      isSynced: isSynced ?? this.isSynced,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

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
      'image_url': imageUrl, // NEW: Added to map
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
      stockQuantity: map['stock_quantity'] ?? 0,
      lowStockLimit: map['low_stock_limit'] ?? 5,
      isSynced: map['is_synced'] ?? 0,
      imageUrl: map['image_url'], // NEW: Added from map
    );
  }
}