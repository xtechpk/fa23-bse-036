import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../providers/app_provider.dart';
import 'detail_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cat = 'All';

  @override
  Widget build(BuildContext context) {
    final content = Provider.of<ContentProvider>(context);
    final user = Provider.of<AppProvider>(context).currentUser!;
    final isDark = Provider.of<AppProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Mighty News", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: isDark ? Colors.white : Colors.black87)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.yellow : Colors.grey[800]),
            onPressed: () => context.read<AppProvider>().toggleTheme(),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Discover news...",
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (val) => content.fetchBlogs(user.id, query: val, category: _cat),
            ),
          ),
          
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: content.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final c = content.categories[i];
                final isSel = _cat == c;
                return GestureDetector(
                  onTap: () {
                    setState(() => _cat = c);
                    content.fetchBlogs(user.id, category: c);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.blueAccent : (isDark ? Colors.grey[800] : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        c,
                        style: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87), 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Responsive News Feed
          Expanded(
            child: content.isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : content.items.isEmpty 
                  ? const Center(child: Text("No stories found"))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive Logic:
                        // If width > 600 (Tablet), show 2 cards.
                        // If width > 900 (Desktop), show 3 cards.
                        // Otherwise (Mobile), show 1 card.
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85, // Adjusts height vs width of cards
                          ),
                          itemCount: content.items.length,
                          itemBuilder: (ctx, i) {
                            final blog = content.items[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                ]
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(blog: blog))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE SECTION (Reduced Size & Contained)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Hero(
                                        tag: blog.id,
                                        child: Container(
                                          color: isDark ? Colors.black26 : Colors.grey[100], // Background for contained images
                                          child: AspectRatio(
                                            aspectRatio: 4 / 3, // Smaller, more square aspect ratio
                                            child: blog.imagePath != null && File(blog.imagePath!).existsSync()
                                                ? Image.file(
                                                    File(blog.imagePath!), 
                                                    fit: BoxFit.contain, // Shows full object inside
                                                    errorBuilder: (ctx, _, __) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200], 
                                                    child: Icon(Icons.image, size: 40, color: Colors.grey[400])
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // CONTENT SECTION
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(blog.category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                                                ),
                                                const Spacer(),
                                                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text(blog.readTime, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              blog.title, 
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.3),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Spacer(), // Pushes like button to bottom
                                            Row(
                                              children: [
                                                Icon(blog.isLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: blog.isLiked ? Colors.red : Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text("${blog.likes}", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }
}