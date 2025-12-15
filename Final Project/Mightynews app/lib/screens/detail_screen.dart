import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/app_models.dart';
import '../providers/blog_provider.dart';
import '../providers/auth_provider.dart';

class DetailScreen extends StatefulWidget {
  final BlogPost blog;
  const DetailScreen({super.key, required this.blog});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BlogProvider>().fetchComments(widget.blog.id));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final blog = provider.items.firstWhere((b) => b.id == widget.blog.id, orElse: () => widget.blog);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (auth.isAdmin) IconButton(icon: const Icon(Icons.delete), onPressed: () {
            provider.deleteBlog(blog.id);
            Navigator.pop(context);
          })
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (blog.imagePath != null) Image.file(File(blog.imagePath!), height: 200, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(blog.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("By ${blog.author} • ${DateFormat('MMM dd').format(blog.date)}", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      Text(blog.content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.thumb_up),
                        label: Text("Like (${blog.likes})"),
                        onPressed: () => provider.likePost(blog.id),
                      ),
                      const Divider(),
                      const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...provider.comments.map((c) => ListTile(
                        dense: true,
                        title: Text(c.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.text),
                        trailing: Text(DateFormat('HH:mm').format(c.date)),
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _commentCtrl, decoration: const InputDecoration(hintText: "Write comment..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: () {
                  if (_commentCtrl.text.isNotEmpty) {
                    provider.addComment(blog.id, auth.user?.username ?? 'Guest', _commentCtrl.text);
                    _commentCtrl.clear();
                  }
                })
              ],
            ),
          )
        ],
      ),
    );
  }
}