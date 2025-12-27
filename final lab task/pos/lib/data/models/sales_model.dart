class SalesModel {
  final String id;
  final double totalAmount;
  final double totalProfit;
  final String customerName;
  final String date;
  final int isSynced;

  SalesModel({
    required this.id,
    required this.totalAmount,
    required this.totalProfit,
    required this.customerName,
    required this.date,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'total_profit': totalProfit,
      'customer_name': customerName,
      'date': date,
      'is_synced': isSynced,
    };
  }
}