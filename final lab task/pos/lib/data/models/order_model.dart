import 'dart:convert';
import 'product_model.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final double totalAmount;
  final String paymentType; // 'Net' or 'Installment'
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentType,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total': totalAmount,
      'payment_type': paymentType,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalAmount: map['total'],
      paymentType: map['payment_type'],
      items: (jsonDecode(map['items']) as List)
          .map((e) => OrderItem.fromMap(e))
          .toList(),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  OrderItem({required this.productId, required this.name, required this.price, required this.quantity});

  Map<String, dynamic> toMap() => {'productId': productId, 'name': name, 'price': price, 'quantity': quantity};

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}