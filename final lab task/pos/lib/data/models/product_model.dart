class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  final double costPrice;
  final double sellingPrice;
  int stockQuantity;
  final int lowStockLimit;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    this.stockQuantity = 0,
    this.lowStockLimit = 5,
    this.imageUrl,
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
      'image_url': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: map['stock_quantity'] ?? 0,
      lowStockLimit: map['low_stock_limit'] ?? 5,
      imageUrl: map['image_url'],
    );
  }
}