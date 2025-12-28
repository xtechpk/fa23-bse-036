import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty 
              ? _buildEmptyState()
              : _buildProductList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigates to the named route defined in main.dart
          await Navigator.pushNamed(context, '/add-product');
          _loadData(); // Refresh list when returning
        },
        label: const Text("ADD PRODUCT"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.inventory_2, color: Colors.blueAccent)),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("SKU: ${p.sku} | Stock: ${p.stockQuantity}"),
            trailing: Text("Rs. ${p.sellingPrice}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Your inventory is empty", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/add-product'), child: const Text("Add First Product")),
        ],
      ),
    );
  }
}