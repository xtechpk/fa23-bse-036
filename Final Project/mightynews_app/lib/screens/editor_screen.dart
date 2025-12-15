import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../providers/content_provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final tCtrl = TextEditingController();
  final cCtrl = TextEditingController();
  String cat = 'Technology';
  XFile? img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Write Story"), actions: [
        TextButton(onPressed: _save, child: const Text("PUBLISH"))
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (file != null) setState(() => img = file);
            },
            child: Container(
              height: 200, color: Colors.grey[200],
              child: img != null ? Image.file(File(img!.path), fit: BoxFit.cover) : const Icon(Icons.add_a_photo, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            isExpanded: true,
            value: cat,
            items: ['Technology', 'Business', 'Health', 'Design', 'Sports', 'World'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => cat = v!),
          ),
          TextField(controller: tCtrl, decoration: const InputDecoration(labelText: "Title")),
          const SizedBox(height: 10),
          TextField(controller: cCtrl, maxLines: 15, decoration: const InputDecoration(labelText: "Content", border: OutlineInputBorder())),
        ],
      ),
    );
  }

  void _save() {
    if (tCtrl.text.isEmpty) return;
    final user = context.read<AppProvider>().currentUser!;
    final blog = BlogPost(
      id: const Uuid().v4(),
      title: tCtrl.text,
      content: cCtrl.text,
      author: user.username,
      date: DateTime.now(),
      category: cat,
      imagePath: img?.path,
    );
    context.read<ContentProvider>().addBlog(blog);
    Navigator.pop(context);
  }
}