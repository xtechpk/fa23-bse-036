import 'package:flutter/material.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/models/product_model.dart';
import '../../core/utils/responsive.dart';

class InventoryListScreen extends StatelessWidget {
  final InventoryRepository _repo = InventoryRepository();

  InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Stock Management", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _repo.fetchAll(), // Fetching all items for the management view
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final items = snapshot.data!;

          return Responsive(
            // MOBILE: Clean cards with status indicators
            mobile: _buildMobileList(items),
            
            // TABLET & DESKTOP: Professional Data Table
            desktop: _buildDesktopTable(items),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-product'),
        backgroundColor: Colors.blueAccent,
        label: const Text("ADD PRODUCT", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- MOBILE VIEW ---
  Widget _buildMobileList(List<ProductModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isLowStock = item.stock <= (item.lowStockLimit ?? 5);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("SKU: ${item.sku}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item.stock}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLowStock ? Colors.red : Colors.green,
                  ),
                ),
                Text(isLowStock ? "Low Stock" : "In Stock",
                    style: TextStyle(fontSize: 10, color: isLowStock ? Colors.red : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DESKTOP VIEW ---
  Widget _buildDesktopTable(List<ProductModel> items) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Inventory Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(label: Text("Product Name")),
                  DataColumn(label: Text("SKU")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Stock Level")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: items.map((item) {
                  bool isLowStock = item.stock <= (item.lowStockLimit ?? 5);
                  return DataRow(cells: [
                    DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(item.sku)),
                    DataCell(Text(item.category ?? "General")),
                    DataCell(Text("Rs. ${item.price}")),
                    DataCell(_buildStockBadge(item.stock, isLowStock)),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () {}),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(int stock, bool isLow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLow ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$stock Units",
        style: TextStyle(color: isLow ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No items in inventory", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}