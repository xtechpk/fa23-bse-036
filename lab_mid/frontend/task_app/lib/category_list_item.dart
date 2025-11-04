import 'package:flutter/material.dart';
import 'package:task_app/category_model.dart';
import 'package:task_app/category_service.dart';
import 'package:task_app/update_category_screen.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final Function onCategoryUpdated;
  final Function onCategoryDeleted;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onCategoryUpdated,
    required this.onCategoryDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(category.name),
        subtitle:
            category.description != null && category.description!.isNotEmpty
                ? Text(category.description!)
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Show the update form in a modal bottom sheet
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom),
                      child: UpdateCategoryScreen(category: category),
                    );
                  },
                );
                if (result == true) {
                  onCategoryUpdated();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this category?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  try {
                    await CategoryService().deleteCategory(id: category.id);
                    onCategoryDeleted();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to delete category: ${e.toString().replaceFirst("Exception: ", "")}')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
