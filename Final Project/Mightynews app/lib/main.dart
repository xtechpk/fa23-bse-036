import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// Ye package Images aur HTML ko render karega
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; 

void main() {
  runApp(const MightyNewsApp());
}

class MightyNewsApp extends StatelessWidget {
  const MightyNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MightyNews Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        // Professional Light Theme (Better for Reading)
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87, 
            fontSize: 20, 
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF052962), // Guardian Blue
          secondary: Color(0xFFFFC107), // Accent Yellow
        ),
      ),
      home: const NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  // Free Key for Development
  final String apiKey = 'test'; 
  
  List<dynamic> articles = [];
  bool isLoading = true;
  String section = 'technology'; 

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => isLoading = true);

    // NOTE: 'show-fields=body' ka matlab hai HTML content (Images ke sath)
    String url = 'https://content.guardianapis.com/search?q=$section&api-key=$apiKey&show-fields=thumbnail,headline,body,byline,lastModified&page-size=15';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['response']['results'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _changeSection(String newSection) {
    setState(() {
      section = newSection;
    });
    Navigator.pop(context);
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.toUpperCase()),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : articles.isEmpty 
            ? const Center(child: Text("No news found")) 
            : ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: articles.length,
                separatorBuilder: (ctx, i) => const Divider(height: 30),
                itemBuilder: (context, index) {
                  return NewsCard(article: articles[index]);
                },
              ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF052962)),
            accountName: Text("MightyNews Pro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            accountEmail: Text("Student Project Edition"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.school, color: Color(0xFF052962), size: 30),
            ),
          ),
          _drawerItem(Icons.memory, "Technology", 'technology'),
          _drawerItem(Icons.sports_soccer, "Sport", 'sport'),
          _drawerItem(Icons.business, "Business", 'business'),
          _drawerItem(Icons.public, "World News", 'world'),
          _drawerItem(Icons.movie, "Film & Movies", 'film'),
          _drawerItem(Icons.science, "Science", 'science'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String key) {
    bool isSelected = section == key;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue[900] : Colors.grey[600]),
      title: Text(title, style: TextStyle(
        color: isSelected ? Colors.blue[900] : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      )),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.05),
      onTap: () => _changeSection(key),
    );
  }
}

class NewsCard extends StatelessWidget {
  final dynamic article;
  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final fields = article['fields'] ?? {};
    final title = fields['headline'] ?? article['webTitle'] ?? '';
    final imageUrl = fields['thumbnail'];
    // Ye 'body' field hai jisme HTML (Images + Text) hai
    final htmlContent = fields['body'] ?? ''; 
    final dateRaw = article['webPublicationDate'] ?? '';
    final author = fields['byline'] ?? 'Guardian Editor';

    String dateDisplay = dateRaw;
    try {
      final DateTime dt = DateTime.parse(dateRaw);
      dateDisplay = DateFormat.yMMMd().format(dt);
    } catch (_) {}

    return InkWell(
      onTap: () {
        // Navigate to Full Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPro(
              title: title,
              imageUrl: imageUrl,
              htmlContent: htmlContent, // Sending HTML content
              date: dateDisplay,
              author: author,
              section: article['sectionName'] ?? 'News',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl, 
                height: 200, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)
                ),
              ),
            ),
          const SizedBox(height: 12),
          
          // Category Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF052962),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (article['sectionName'] ?? 'General').toString().toUpperCase(), 
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.2)),
          
          const SizedBox(height: 8),
          
          // Date & Author
          Row(
            children: [
              Text(dateDisplay, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Spacer(),
              const Icon(Icons.edit_note, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(author, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// PROFESSIONAL DETAIL SCREEN (HTML RENDERER)
// ---------------------------------------------------------
class ArticleDetailPro extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String htmlContent; // HTML String
  final String date;
  final String author;
  final String section;

  const ArticleDetailPro({
    super.key, 
    required this.title, 
    required this.imageUrl, 
    required this.htmlContent,
    required this.date,
    required this.author,
    required this.section
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar with Image
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null 
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black12,
                    colorBlendMode: BlendMode.darken,
                  ) 
                : Container(color: Colors.grey[200]),
            ),
          ),
          
          // Article Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Data
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF052962),
                        child: Text(section[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Main Headline
                  Text(
                    title,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, fontFamily: 'Georgia'),
                  ),
                  
                  const SizedBox(height: 10),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),

                  // 🔴 THE MAGIC PART: HTML WIDGET
                  // Ye widget HTML ko parse karega aur images/formatting dikhayega
                  HtmlWidget(
                    htmlContent,
                    textStyle: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
                    customStylesBuilder: (element) {
                      // Adjust styling for specific tags if needed
                      if (element.localName == 'p') {
                        return {'margin-bottom': '16px'};
                      }
                      return null;
                    },
                    onErrorBuilder: (context, element, error) => Text('$element error: $error'),
                    onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
                    renderMode: RenderMode.column,
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Text("End of Article • MightyNews", 
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}