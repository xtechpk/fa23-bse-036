import 'package:flutter/material.dart';
import 'package:task_app/category_model.dart';
import 'package:task_app/category_list_item.dart';
import 'package:task_app/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  final VoidCallback? onCategoryCreated;
  const CategoriesScreen({super.key, this.onCategoryCreated});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _categoriesFuture;
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchAndSetCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Category>> _fetchAndSetCategories() async {
    final categories = await CategoryService().getCategories();
    _allCategories = categories;
    _filteredCategories = categories;
    return categories;
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((category) => category.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void refreshCategories() {
    setState(() {
      _categoriesFuture = _fetchAndSetCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Categories',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (_allCategories.isEmpty) {
                return const Center(child: Text('No categories found.'));
              }

              return RefreshIndicator(
                onRefresh: () async => refreshCategories(),
                child: ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return CategoryListItem(
                        category: category,
                        onCategoryUpdated: refreshCategories,
                        onCategoryDeleted: refreshCategories,
                      );
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}
