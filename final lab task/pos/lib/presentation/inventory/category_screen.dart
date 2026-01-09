import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/three_d_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductRepository _repo = ProductRepository();
  bool _isLoading = true;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _repo.fetchAllCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final newCat = CategoryModel(id: const Uuid().v4(), name: name);
                await _repo.addCategory(newCat);
                await _loadCategories();
                if (!mounted) return;
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(CategoryModel cat) {
    final ctrl = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final updated = CategoryModel(id: cat.id, name: name);
                await _repo.updateCategory(updated);
                await _loadCategories();
                if (!mounted) return;
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(CategoryModel cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await _repo.deleteCategory(cat.id);
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No categories found', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _showAddDialog, child: const Text('Add Category')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final c = _categories[index];
                    return EntranceFader(
                      delay: Duration(milliseconds: index * 50),
                      child: ThreeDCard(
                      type: ThreeDType.lift,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [const Icon(Icons.label_outline), const SizedBox(width: 12), Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold))]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditDialog(c)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(c)),
                        ])
                      ]),
                    ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
