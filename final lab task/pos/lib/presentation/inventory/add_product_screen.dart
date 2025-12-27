import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/utils/responsive.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers matching your specific ProductModel
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _lowStockCtrl = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  final _repo = ProductRepository();

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        // Prepare your Image URL (In a real app, you'd upload _imageFile to Supabase/Firebase here)
        String? imageUrl; 
        if (_imageFile != null) {
          // Placeholder for your upload logic: 
          // imageUrl = await _repo.uploadImage(_imageFile!);
        }

        final newProduct = ProductModel(
          id: const Uuid().v4(),
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim(),
          costPrice: double.parse(_costPriceCtrl.text),
          sellingPrice: double.parse(_sellingPriceCtrl.text),
          stockQuantity: int.parse(_stockCtrl.text),
          category: _categoryCtrl.text.isEmpty ? "General" : _categoryCtrl.text,
          lowStockLimit: int.tryParse(_lowStockCtrl.text) ?? 5,
          imageUrl: imageUrl, // Mapping the image URL
        );

        await _repo.addProduct(newProduct);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product Added Successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Add New Product"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- IMAGE PICKER SECTION ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(_imageFile!, fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.blueAccent, size: 40),
                                SizedBox(height: 8),
                                Text("Add Image", style: TextStyle(color: Colors.blueAccent)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- FORM FIELDS ---
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Product Name"),
                        _buildTextField(_nameCtrl, "e.g. Chocolate Cake", Icons.shopping_bag_outlined),
                        
                        const SizedBox(height: 20),
                        _buildLabel("SKU / Barcode"),
                        _buildTextField(_skuCtrl, "e.g. BC-001", Icons.qr_code_scanner),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Cost Price (Buy)"),
                                _buildTextField(_costPriceCtrl, "0.00", Icons.download, isNumber: true),
                              ],
                            )),
                            const SizedBox(width: 20),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Selling Price (Sell)"),
                                _buildTextField(_sellingPriceCtrl, "0.00", Icons.upload, isNumber: true),
                              ],
                            )),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Initial Stock"),
                                _buildTextField(_stockCtrl, "0", Icons.inventory_2_outlined, isNumber: true),
                              ],
                            )),
                            const SizedBox(width: 20),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Low Stock Limit"),
                                _buildTextField(_lowStockCtrl, "5", Icons.warning_amber_rounded, isNumber: true),
                              ],
                            )),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        _isSaving 
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Save Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}