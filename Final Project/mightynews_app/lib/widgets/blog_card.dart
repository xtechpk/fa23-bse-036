import 'dart:io';
import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../screens/detail_screen.dart';

class BlogCard extends StatelessWidget {
  final BlogPost blog;
  const BlogCard({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(blog: blog))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imagePath != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(blog.imagePath!), 
                  height: 180, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(height: 180, color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(blog.category, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(blog.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("By ${blog.author} • ${blog.readTime}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}