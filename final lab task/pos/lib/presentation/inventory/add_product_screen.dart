import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ProductRepository();

  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _lowStockCtrl = TextEditingController();

  String? _selectedCategory;
  List<CategoryModel> _categories = [];
  
  XFile? _pickedFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _repo.fetchAllCategories();
    setState(() => _categories = cats);
  }

  void _showAddCategoryDialog() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: catCtrl,
          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (catCtrl.text.isNotEmpty) {
                final newCat = CategoryModel(id: const Uuid().v4(), name: catCtrl.text.trim());
                await _repo.addCategory(newCat);
                await _loadCategories();
                setState(() => _selectedCategory = newCat.name);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() { _webImage = bytes; _pickedFile = image; });
        } else {
          setState(() { _pickedFile = image; });
        }
      }
    } catch (e) { debugPrint("Image Pick Error: $e"); }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final newProduct = ProductModel(
          id: const Uuid().v4(),
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim(),
          costPrice: double.tryParse(_costPriceCtrl.text) ?? 0.0,
          sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0.0,
          stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
          category: _selectedCategory ?? "General",
          lowStockLimit: int.tryParse(_lowStockCtrl.text) ?? 5,
          imageUrl: _pickedFile?.path,
        );

        await _repo.addProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Saved!"), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      } finally { if (mounted) setState(() => _isSaving = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 30),
              _buildField(_nameCtrl, "Product Name", Icons.edit),
              _buildField(_skuCtrl, "SKU / Barcode", Icons.qr_code),
              
              // --- CATEGORY SELECTOR ---
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Select Category",
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 35),
                    )
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(child: _buildField(_costPriceCtrl, "Cost Price", Icons.download, isNum: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_sellingPriceCtrl, "Selling Price", Icons.upload, isNum: true)),
                ],
              ),
              _buildField(_stockCtrl, "Initial Stock", Icons.inventory, isNum: true),
              _buildField(_lowStockCtrl, "Low Stock Limit", Icons.warning, isNum: true),
              
              const SizedBox(height: 30),
              _isSaving 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("SAVE PRODUCT", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150, width: 150,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent)),
        child: kIsWeb && _webImage != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_webImage!, fit: BoxFit.cover))
          : _pickedFile != null && !kIsWeb
            ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(_pickedFile!.path), fit: BoxFit.cover))
            : const Icon(Icons.add_a_photo, size: 50, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: hint, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}