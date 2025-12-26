import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/inventory_repository.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryRepository _repo = InventoryRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Management")),
      body: FutureBuilder<List<ProductModel>>(
        future: _repo.fetchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final bool isLow = item.stockQuantity <= item.lowStockLimit;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: isLow ? Colors.red.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLow ? Colors.red : Colors.blue,
                    child: Text(item.category[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Price: \$${item.sellingPrice} | SKU: ${item.sku}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Stock: ${item.stockQuantity}", 
                        style: TextStyle(color: isLow ? Colors.red : Colors.black, fontWeight: FontWeight.bold)),
                      if (isLow) const Text("LOW", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Navigate to your Add Product Screen or show a Dialog
  }
}