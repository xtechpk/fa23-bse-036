import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';
import 'detail_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCat = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BlogProvider>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mighty News")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Search news...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onSubmitted: (val) => provider.loadData(query: val, category: _selectedCat),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: provider.categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _selectedCat == c,
                  onSelected: (sel) {
                    setState(() => _selectedCat = c);
                    provider.loadData(category: c);
                  },
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: provider.isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.items.length,
                  itemBuilder: (ctx, i) {
                    final blog = provider.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(blog: blog))),
                        leading: blog.imagePath != null 
                           ? Image.file(File(blog.imagePath!), width: 60, height: 60, fit: BoxFit.cover)
                           : const Icon(Icons.image, size: 60),
                        title: Text(blog.title, maxLines: 1),
                        subtitle: Text("${blog.category} • ${blog.likes} Likes"),
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
}