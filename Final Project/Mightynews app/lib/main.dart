import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // KEY FIX FOR WEB
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlogProvider()),
      ],
      child: const MightyBlogApp(),
    ),
  );
}

// ---------------------------------------------------------
// 1. ROBUST DATA MODEL
// ---------------------------------------------------------
class BlogPost {
  final String id;
  String title;
  String content;
  String author;
  DateTime date;
  String category;
  String? imagePath;    // Local path (Mobile) or Blob URL (Web)
  String? networkImage; // URL from Internet
  bool isBookmarked;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.category,
    this.imagePath,
    this.networkImage,
    this.isBookmarked = false,
  });

  // Calculate Read Time
  String get readTime {
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes min read';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'author': author,
    'date': date.toIso8601String(),
    'category': category,
    'imagePath': imagePath,
    'networkImage': networkImage,
    'isBookmarked': isBookmarked,
  };

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    author: json['author'],
    date: DateTime.parse(json['date']),
    category: json['category'],
    imagePath: json['imagePath'],
    networkImage: json['networkImage'],
    isBookmarked: json['isBookmarked'] ?? false,
  );
}

// ---------------------------------------------------------
// 2. PROVIDER (Business Logic)
// ---------------------------------------------------------
class BlogProvider extends ChangeNotifier {
  List<BlogPost> _items = [];
  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  List<BlogPost> get items => [..._items];
  List<BlogPost> get bookmarkedItems => _items.where((i) => i.isBookmarked).toList();

  int get totalPosts => _items.length;
  int get totalWords => _items.fold(0, (sum, item) => sum + item.content.split(' ').length);

  BlogProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final String? blogsString = prefs.getString('blogs');
    
    if (blogsString != null) {
      final List<dynamic> decoded = jsonDecode(blogsString);
      _items = decoded.map((item) => BlogPost.fromJson(item)).toList();
    } else {
      _items = _getDummyData(); // Load starter content
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('blogs', encoded);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveData();
    notifyListeners();
  }

  void addBlog(BlogPost blog) {
    _items.insert(0, blog);
    _saveData();
    notifyListeners();
  }

  void updateBlog(BlogPost updated) {
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      _saveData();
      notifyListeners();
    }
  }

  void deleteBlog(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleBookmark(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isBookmarked = !_items[index].isBookmarked;
      _saveData();
      notifyListeners();
    }
  }

  List<BlogPost> _getDummyData() {
    return [
      BlogPost(
        id: const Uuid().v4(),
        title: 'Design Systems 101',
        content: 'A design system is a collection of reusable components, guided by clear standards, that can be assembled together to build any number of applications.',
        author: 'Sarah UX',
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Design',
        networkImage: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80',
      ),
       BlogPost(
        id: const Uuid().v4(),
        title: 'The Future of AI',
        content: 'Artificial intelligence is reshaping how we work, live, and interact with the world around us. From generative models to autonomous agents...',
        author: 'Tech Daily',
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Technology',
        networkImage: 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800&q=80',
      ),
    ];
  }
}

// ---------------------------------------------------------
// 3. APP CONFIGURATION
// ---------------------------------------------------------
class MightyBlogApp extends StatelessWidget {
  const MightyBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    
    return MaterialApp(
      title: 'MightyBlog Pro',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const MainLayout(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Professional Color Palette
    final bg = isDark ? const Color(0xFF0F1115) : const Color(0xFFFAFAFA); // Almost black vs Off-white
    final surface = isDark ? const Color(0xFF181B21) : Colors.white;
    final primary = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F172A); // Slate 900
    
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F172A), 
        brightness: brightness,
        primary: primary,
        surface: surface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme( // Modern Geometric Font
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Remove M3 tint
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: isDark ? Colors.white : const Color(0xFF0F172A), 
          fontSize: 20, 
          fontWeight: FontWeight.w700
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white70 : const Color(0xFF0F172A)),
      ),
      useMaterial3: true,
    );
  }
}

// ---------------------------------------------------------
// 4. MAIN LAYOUT (Bottom Nav)
// ---------------------------------------------------------
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;
  final _screens = const [HomeTab(), BookmarksTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens), // Persist state between tabs
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: isDark ? const Color(0xFF181B21) : Colors.white,
        elevation: 10,
        shadowColor: Colors.black26,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined), 
            selectedIcon: Icon(Icons.grid_view_rounded), 
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded), 
            selectedIcon: Icon(Icons.bookmark_rounded), 
            label: 'Saved'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded), 
            selectedIcon: Icon(Icons.person_rounded), 
            label: 'Profile'
          ),
        ],
      ),
      floatingActionButton: _index == 0 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen())),
            backgroundColor: isDark ? Colors.blueAccent : const Color(0xFF0F172A),
            elevation: 4,
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Write", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }
}

// ---------------------------------------------------------
// 5. UNIVERSAL IMAGE WIDGET (CRITICAL FIX FOR WEB)
// ---------------------------------------------------------
class UniversalImage extends StatelessWidget {
  final String? path;
  final String? url;
  final double height;
  final double width;

  const UniversalImage({
    super.key, 
    this.path, 
    this.url, 
    this.height = 200, 
    this.width = double.infinity
  });

  @override
  Widget build(BuildContext context) {
    // 1. If Network URL exists, use it
    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_,__,___) => _buildPlaceholder(),
      );
    }

    // 2. If Local Path exists
    if (path != null && path!.isNotEmpty) {
      // 🔴 WEB FIX: On Web, we treat the 'path' as a Network Blob URL
      if (kIsWeb) {
        return Image.network(
          path!,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (_,__,___) => _buildPlaceholder(),
        );
      } 
      // 📱 MOBILE FIX: Use File IO
      else {
        return Image.file(
          File(path!),
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (_,__,___) => _buildPlaceholder(),
        );
      }
    }

    // 3. Fallback
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. UI TABS
// ---------------------------------------------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    final blogs = provider.items;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: Text("MightyBlog", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
              icon: Icon(provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () => provider.toggleTheme(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        if (blogs.isEmpty)
           const SliverFillRemaining(
            child: Center(child: Text("No stories found. Start writing!")),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ProBlogCard(blog: blogs[i]),
                childCount: blogs.length,
              ),
            ),
          ),
      ],
    );
  }
}

class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    final blogs = provider.bookmarkedItems;

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Stories")),
      body: blogs.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bookmark_outline, size: 60, color: Colors.grey), SizedBox(height: 10), Text("Nothing saved yet")]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blogs.length,
              itemBuilder: (ctx, i) => ProBlogCard(blog: blogs[i]),
            ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2)),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF0F172A),
                  child: Text("MB", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              Text("Mighty Creator", style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Member since 2025", style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 30),
              
              Row(
                children: [
                  Expanded(child: _StatBox(label: "Posts", value: "${provider.totalPosts}")),
                  const SizedBox(width: 15),
                  Expanded(child: _StatBox(label: "Words", value: "${provider.totalWords}")),
                ],
              ),
              const SizedBox(height: 40),
              const ListTile(leading: Icon(Icons.settings), title: Text("Settings"), trailing: Icon(Icons.chevron_right)),
              const ListTile(leading: Icon(Icons.help_outline), title: Text("Help & Support"), trailing: Icon(Icons.chevron_right)),
              const ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout", style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 7. PRO BLOG CARD (Refined UI)
// ---------------------------------------------------------
class ProBlogCard extends StatelessWidget {
  final BlogPost blog;
  const ProBlogCard({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Hero(
                  tag: 'img_${blog.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: UniversalImage(path: blog.imagePath, url: blog.networkImage, height: 220),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      blog.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            
            // Text Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.grey[200], child: const Icon(Icons.person, size: 12, color: Colors.black)),
                      const SizedBox(width: 8),
                      Text(blog.author, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(blog.readTime, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 8. EDITOR SCREEN (Fixes Image Picking)
// ---------------------------------------------------------
class EditorScreen extends StatefulWidget {
  final BlogPost? blogToEdit;
  const EditorScreen({super.key, this.blogToEdit});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _authorCtrl;
  String _category = 'Technology';
  XFile? _pickedFile; // Use XFile to support Web and Mobile
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final b = widget.blogToEdit;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _contentCtrl = TextEditingController(text: b?.content ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    if (b != null) _category = b.category;
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<BlogProvider>();
      
      // Determine Image Path (Use local picked path OR existing path)
      String? finalImagePath;
      if (_pickedFile != null) {
        finalImagePath = _pickedFile!.path;
      } else if (widget.blogToEdit != null) {
        finalImagePath = widget.blogToEdit!.imagePath;
      }

      final newBlog = BlogPost(
        id: widget.blogToEdit?.id ?? const Uuid().v4(),
        title: _titleCtrl.text,
        content: _contentCtrl.text,
        author: _authorCtrl.text.isEmpty ? 'Anonymous' : _authorCtrl.text,
        date: widget.blogToEdit?.date ?? DateTime.now(),
        category: _category,
        imagePath: finalImagePath,
        networkImage: widget.blogToEdit?.networkImage,
        isBookmarked: widget.blogToEdit?.isBookmarked ?? false,
      );

      if (widget.blogToEdit == null) {
        provider.addBlog(newBlog);
      } else {
        provider.updateBlog(newBlog);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blogToEdit == null ? "New Story" : "Editing"),
        actions: [
          TextButton(onPressed: _save, child: const Text("Publish", style: TextStyle(fontWeight: FontWeight.bold)))
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.1),
                  child: _pickedFile != null
                      ? UniversalImage(path: _pickedFile!.path, height: 250) // Show picked image
                      : (widget.blogToEdit?.imagePath != null || widget.blogToEdit?.networkImage != null)
                          ? UniversalImage(path: widget.blogToEdit?.imagePath, url: widget.blogToEdit?.networkImage, height: 250)
                          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), SizedBox(height: 10), Text("Add Cover Image")]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: "Title...", border: InputBorder.none),
              validator: (v) => v!.isEmpty ? "Title is required" : null,
            ),
            const Divider(),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(border: InputBorder.none),
              items: ['Technology', 'Design', 'Business', 'Lifestyle', 'Health'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const Divider(),
            TextFormField(
              controller: _contentCtrl,
              maxLines: null,
              style: const TextStyle(fontSize: 18, height: 1.6),
              decoration: const InputDecoration(hintText: "Tell your story...", border: InputBorder.none),
              validator: (v) => v!.isEmpty ? "Content is required" : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 9. DETAIL SCREEN
// ---------------------------------------------------------
class BlogDetailScreen extends StatelessWidget {
  final BlogPost blog;
  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlogProvider>(context);
    // Get Live Data
    final currentBlog = provider.items.firstWhere((e) => e.id == blog.id, orElse: () => blog);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            actions: [
              IconButton(icon: Icon(currentBlog.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: currentBlog.isBookmarked ? Colors.blue : null), onPressed: () => provider.toggleBookmark(currentBlog.id)),
              PopupMenuButton(
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text("Edit Story")),
                  const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(blogToEdit: currentBlog)));
                  } else {
                    provider.deleteBlog(currentBlog.id);
                    Navigator.pop(context);
                  }
                },
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'img_${currentBlog.id}',
                child: UniversalImage(path: currentBlog.imagePath, url: currentBlog.networkImage, height: 350),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(currentBlog.category.toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11))),
                      const Spacer(),
                      Text(DateFormat.yMMMd().format(currentBlog.date), style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(currentBlog.title, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 20),
                  Row(children: [const CircleAvatar(radius: 16, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white, size: 16)), const SizedBox(width: 10), Text(currentBlog.author, style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 30),
                  Text(currentBlog.content, style: GoogleFonts.merriweather(fontSize: 18, height: 1.8, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9))),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}