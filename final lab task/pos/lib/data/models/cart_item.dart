import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Calculate subtotal for this specific line item
  double get subtotal => product.sellingPrice * quantity;

  // Calculate profit for this specific line item
  double get totalProfit => (product.sellingPrice - product.costPrice) * quantity;
}