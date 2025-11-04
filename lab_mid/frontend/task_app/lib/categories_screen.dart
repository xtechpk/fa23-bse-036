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

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService().getCategories();
  }

  void refreshCategories() {
    setState(() {
      _categoriesFuture = CategoryService().getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        final categories = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => refreshCategories(),
          child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryListItem(
                  category: category,
                  onCategoryUpdated: refreshCategories,
                  onCategoryDeleted: refreshCategories,
                );
              }),
        );
      },
    );
  }
}
