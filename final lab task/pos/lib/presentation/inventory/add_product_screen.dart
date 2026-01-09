import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

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

  late final bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    _loadCategories();

    // If editing, pre-fill the fields
    if (_isEdit) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _costPriceCtrl.text = p.costPrice.toString();
      _sellingPriceCtrl.text = p.sellingPrice.toString();
      _stockCtrl.text = p.stockQuantity.toString();
      _lowStockCtrl.text = p.lowStockLimit.toString();
      _selectedCategory = p.category;
      if (p.imageUrl != null && p.imageUrl!.isNotEmpty && !kIsWeb) {
        _pickedFile = XFile(p.imageUrl!);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repo.fetchAllCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
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
        final product = ProductModel(
          id: _isEdit ? widget.product!.id : const Uuid().v4(),
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim(),
          costPrice: double.tryParse(_costPriceCtrl.text) ?? 0.0,
          sellingPrice: double.tryParse(_sellingPriceCtrl.text) ?? 0.0,
          stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
          category: _selectedCategory ?? "General",
          lowStockLimit: int.tryParse(_lowStockCtrl.text) ?? 5,
          imageUrl: _pickedFile?.path,
        );

        if (_isEdit) {
          await _repo.updateProduct(product);
        } else {
          await _repo.addProduct(product);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? "Product Updated!" : "Product Saved!"),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      } finally { if (mounted) setState(() => _isSaving = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? "Edit Product" : "Add New Product")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth > 700;
          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!wide) Center(child: _buildImagePicker()),
                if (!wide) const SizedBox(height: 20),

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
                Row(
                  children: [
                    Expanded(child: _buildField(_stockCtrl, "Initial Stock", Icons.inventory, isNum: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(_lowStockCtrl, "Low Stock Limit", Icons.warning, isNum: true)),
                  ],
                ),

                const SizedBox(height: 20),
                _isSaving 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(_isEdit ? "UPDATE PRODUCT" : "SAVE PRODUCT", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left - image
                      SizedBox(width: 300, child: Column(children: [_buildImagePicker(), const SizedBox(height: 12), TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo_library), label: const Text('Change Image'))])),
                      const SizedBox(width: 24),
                      Expanded(child: form),
                    ],
                  )
                : form,
          );
        },
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