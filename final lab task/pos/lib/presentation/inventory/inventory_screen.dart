import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../core/utils/responsive.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryRepository _repo = InventoryRepository();

  // Helper to determine grid columns based on screen width
  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 1; // Mobile
    if (width < 1100) return 2; // Tablet
    if (width < 1600) return 3; // Desktop
    return 4; // Ultra-wide
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Stock & Inventory", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _repo.fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 110, // Consistent height for cards
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final bool isLow = item.stockQuantity <= item.lowStockLimit;
              return _buildInventoryCard(item, isLow);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-product'),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add_box_rounded),
        label: const Text("NEW PRODUCT", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInventoryCard(ProductModel item, bool isLow) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLow ? Colors.red.shade200 : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {}, // Open product details or edit
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Badge
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isLow ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        item.category[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.red : Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.name, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("SKU: ${item.sku}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Rs. ${item.sellingPrice}", 
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Stock Status
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLow ? Colors.red : Colors.green.shade500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${item.stockQuantity}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLow ? "LOW STOCK" : "IN STOCK",
                        style: TextStyle(
                          color: isLow ? Colors.red : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Inventory is empty", 
            style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add-product'),
            child: const Text("Add your first product"),
          )
        ],
      ),
    );
  }
}