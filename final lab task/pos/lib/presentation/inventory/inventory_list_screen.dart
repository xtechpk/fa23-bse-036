// lib/presentation/inventory/inventory_list_screen.dart
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../core/utils/responsive.dart';

class InventoryListScreen extends StatelessWidget {
  final InventoryRepository _repo = InventoryRepository();

  InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Management View")),
      body: FutureBuilder<List<ProductModel>>(
        future: _repo.fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Empty"));

          final items = snapshot.data!;
          return Responsive(
            mobile: _buildMobileList(items),
            desktop: _buildDesktopTable(items),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(List<ProductModel> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        bool isLow = item.stockQuantity <= item.lowStockLimit;
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text("Stock: ${item.stockQuantity}"),
            trailing: Icon(Icons.circle, color: isLow ? Colors.red : Colors.green, size: 12),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<ProductModel> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Product")),
              DataColumn(label: Text("Category")),
              DataColumn(label: Text("Cost")),
              DataColumn(label: Text("Selling")),
              DataColumn(label: Text("Stock")),
              DataColumn(label: Text("Status")),
            ],
            rows: items.map((item) {
              bool isLow = item.stockQuantity <= item.lowStockLimit;
              return DataRow(cells: [
                DataCell(Text(item.name)),
                DataCell(Text(item.category)),
                DataCell(Text("${item.costPrice}")),
                DataCell(Text("${item.sellingPrice}")),
                DataCell(Text("${item.stockQuantity}")),
                DataCell(Text(isLow ? "Low Stock" : "Healthy", style: TextStyle(color: isLow ? Colors.red : Colors.green))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}