// lib/presentation/inventory/inventory_list_screen.dart
import 'package:flutter/material.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/models/product_model.dart';

class InventoryListScreen extends StatelessWidget {
  final InventoryRepository _repo = InventoryRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Management")),
      body: FutureBuilder<List<ProductModel>>(
        future: _repo.getLowStockItems(), // Highlight alerts first
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text("SKU: ${item.sku} | Cat: ${item.category}"),
                trailing: Text(
                  "Stock: ${item.stock}",
                  style: TextStyle(
                    color: item.stock <= item.lowStockLimit ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}