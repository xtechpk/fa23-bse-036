import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../providers/blog_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_models.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  String category = 'Technology';
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Write Story"), actions: [
        TextButton(onPressed: () {
          if (titleCtrl.text.isEmpty) return;
          final blog = BlogPost(
            id: const Uuid().v4(),
            title: titleCtrl.text,
            content: contentCtrl.text,
            author: context.read<AuthProvider>().user?.username ?? 'Admin',
            date: DateTime.now(),
            category: category,
            imagePath: image?.path,
          );
          context.read<BlogProvider>().addBlog(blog);
          Navigator.pop(context);
        }, child: const Text("PUBLISH"))
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () async {
              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (img != null) setState(() => image = img);
            },
            child: Container(
              height: 200, color: Colors.grey[200],
              child: image != null ? Image.file(File(image!.path), fit: BoxFit.cover) : const Icon(Icons.add_photo_alternate, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: category,
            isExpanded: true,
            items: ['Technology', 'Business', 'Health', 'Design', 'Sports'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => category = v!),
          ),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
          TextField(controller: contentCtrl, maxLines: 10, decoration: const InputDecoration(labelText: "Content")),
        ],
      ),
    );
  }
}