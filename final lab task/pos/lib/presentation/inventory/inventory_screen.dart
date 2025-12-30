import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/three_d_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductRepository _productRepo = ProductRepository();
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _productRepo.fetchAllProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (_products.isEmpty) return _buildEmptyState();
                final isWide = constraints.maxWidth > 800;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12),
                          itemCount: _products.length,
                          itemBuilder: (context, i) => _productCard(_products[i], i),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: _products.length,
                          itemBuilder: (context, i) => _productCard(_products[i], i),
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.pushNamed(context, '/add-product');
          if (res == true) await _loadData(); // Refresh if product was added/updated
        },
        label: const Text("ADD PRODUCT"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _productCard(ProductModel p, int index) {
    bool isLowStock = p.stockQuantity <= p.lowStockLimit;
    return EntranceFader(
      delay: Duration(milliseconds: index * 50),
      child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ThreeDCard(
        type: ThreeDType.lift,
        onTap: () async {
          final res = await Navigator.pushNamed(context, '/edit-product', arguments: p);
          if (res == true) await _loadData();
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100]),
                  child: p.imageUrl != null && p.imageUrl!.isNotEmpty && !kIsWeb
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(p.imageUrl!), fit: BoxFit.cover))
                      : const Icon(Icons.inventory_2_outlined,
                          size: 36, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text('SKU: ${p.sku}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, children: [
                          Chip(label: Text(p.category)),
                          Text('Stock: ${p.stockQuantity}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isLowStock ? Colors.red : Colors.grey))
                        ]),
                      ]),
                ),
                const SizedBox(width: 12),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs. ${p.sellingPrice}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      IconButton(
                        onPressed: () async {
                          final confirm = await _confirmProductDelete(p.name);
                          if (confirm == true) {
                            // TODO: Implement actual delete logic via repository
                            // await _productRepo.deleteProduct(p.id);
                            // await _loadData();
                          }
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ]),
              ],
            ),
      ),
    ),
    );
  }

  Future<bool?> _confirmProductDelete(String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'))
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Your inventory is empty",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-product'),
              child: const Text("Add First Product")),
        ],
      ),
    );
  }
}