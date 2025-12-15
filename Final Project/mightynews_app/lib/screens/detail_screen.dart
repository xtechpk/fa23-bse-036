import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/content_provider.dart';
import '../providers/app_provider.dart';

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
    // Load comments on open
    Future.microtask(() => context.read<ContentProvider>().fetchComments(widget.blog.id));
  }

  @override
  Widget build(BuildContext context) {
    final content = Provider.of<ContentProvider>(context);
    final user = Provider.of<AppProvider>(context, listen: false).currentUser!;
    final isDark = Provider.of<AppProvider>(context).isDarkMode;

    // Get live data (so likes update instantly)
    final blog = content.items.firstWhere((b) => b.id == widget.blog.id, orElse: () => widget.blog);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(blog.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                  onPressed: () => content.toggleBookmark(user.id, blog.id),
                ),
              ),
              if (user.isAdmin)
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () {
                    content.deleteBlog(blog.id);
                    Navigator.pop(context);
                  }),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: blog.id,
                child: blog.imagePath != null && File(blog.imagePath!).existsSync()
                    ? Image.file(File(blog.imagePath!), fit: BoxFit.cover)
                    : Container(color: Colors.grey[800], child: const Icon(Icons.image, size: 80, color: Colors.white24)),
              ),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Overlap effect
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Data
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                          child: Text(blog.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const Spacer(),
                        Text(DateFormat.yMMMd().format(blog.date), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(blog.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.2)),
                    const SizedBox(height: 10),
                    Text("By ${blog.author}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 25),

                    // Body
                    Text(
                      blog.content, 
                      style: TextStyle(fontSize: 18, height: 1.8, color: isDark ? Colors.grey[300] : Colors.grey[800], fontFamily: 'Georgia'),
                    ),
                    const SizedBox(height: 40),

                    // LIKE TOGGLE BUTTON
                    GestureDetector(
                      onTap: () => content.toggleLike(user.id, blog.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: blog.isLiked ? Colors.pink.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: blog.isLiked ? Colors.pink : Colors.grey)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(blog.isLiked ? Icons.favorite : Icons.favorite_border, color: blog.isLiked ? Colors.pink : Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              blog.isLiked ? "Liked (${blog.likes})" : "Like this story (${blog.likes})",
                              style: TextStyle(color: blog.isLiked ? Colors.pink : Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Text("Discussion", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    // Comments List
                    ...content.comments.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18, 
                            backgroundColor: Colors.blueAccent, 
                            child: Text(c.username[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(c.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(DateFormat('MMM d, HH:mm').format(c.date), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(c.text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                    if (content.comments.isEmpty) 
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No comments yet. Be the first!"))),
                    
                    const SizedBox(height: 80), // Space for bottom input
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      
      // Floating Comment Input
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentCtrl, 
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () {
                  if (_commentCtrl.text.isNotEmpty) {
                    content.addComment(blog.id, user.username, _commentCtrl.text);
                    _commentCtrl.clear();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}