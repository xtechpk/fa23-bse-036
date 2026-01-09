import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/product_repository.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final ProductRepository _repo = ProductRepository();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final data = await _repo.fetchAllOrders();
    if (mounted) setState(() { _orders = data; _isLoading = false; });
  }

  Future<void> _processReturn(OrderModel order, OrderItem item) async {
    // Ask for quantity
    final controller = TextEditingController(text: "1");
    final qty = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Return ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter quantity to return:"),
            TextField(controller: controller, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text("Policy: 7 Days Return. Item must be unused.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0 && val <= item.quantity) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text("Confirm Return"),
          )
        ],
      ),
    );

    if (qty != null) {
      await _repo.updateStock(item.productId, qty); // Add back to stock
      // In a real app, we would update the order record to reflect the return.
      // For now, we just update inventory and show success.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Returned $qty x ${item.name} to inventory.")));
        _loadOrders(); // Refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Returns & Orders")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return ExpansionTile(
                      title: Text("Order #${order.id}"),
                      subtitle: Text("${DateFormat('yyyy-MM-dd').format(order.date)} - ${order.paymentType}"),
                      trailing: Text("Rs. ${order.totalAmount}"),
                      children: order.items.map((item) {
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text("Qty Sold: ${item.quantity}"),
                          trailing: TextButton(
                            onPressed: () => _processReturn(order, item),
                            child: const Text("Return"),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }
}