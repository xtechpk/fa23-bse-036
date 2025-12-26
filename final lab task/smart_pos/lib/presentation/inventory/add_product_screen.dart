import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _repo = ProductRepository();

  void _saveProduct() async {
    final newProduct = ProductModel(
      id: const Uuid().v4(), // Unique ID for each item
      name: _nameCtrl.text,
      sku: _skuCtrl.text,
      price: double.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
    );

    await _repo.addProduct(newProduct);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product Added Successfully!"))
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Product Name (e.g. Cake)")),
            TextField(controller: _skuCtrl, decoration: const InputDecoration(labelText: "SKU / Barcode")),
            TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: _stockCtrl, decoration: const InputDecoration(labelText: "Initial Stock"), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}