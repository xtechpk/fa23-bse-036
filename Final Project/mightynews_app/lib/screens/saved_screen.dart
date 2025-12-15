import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import 'detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Provider.of<ContentProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Stories")),
      body: content.savedItems.isEmpty 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bookmark_outline, size: 50, color: Colors.grey), SizedBox(height: 10), Text("No bookmarks yet")]))
        : ListView.builder(
            itemCount: content.savedItems.length,
            itemBuilder: (ctx, i) {
              final blog = content.savedItems[i];
              return ListTile(
                title: Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(blog.category),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(blog: blog))),
              );
            },
          ),
    );
  }
}