import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

// --- DATA MODELS ---

class MenuItem {
  final String id;
  String name;
  double price;
  String category;
  int quantity; // Only used in the Cart

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num?)?.toDouble() ?? 0.0, // Safeguard
        category: json['category'] as String,
      );
}

class Customer {
  final String id;
  String name;
  String phoneNumber;
  double balance;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'balance': balance,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String? ?? 'N/A',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0, // Safeguard
      );

  static Customer walkIn = Customer(
      id: 'walk_in', name: 'Walk-in Customer', phoneNumber: '', balance: 0.0);
}

class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}

class Transaction {
  final String id;
  final DateTime timestamp;
  final String customerName;
  final double totalAmount;
  final double tax;
  final double subtotal;
  final List<MenuItem> items;
  final double customerOldBalance;
  final double customerNewBalance;
  final String operatorName;
  final double amountPaid;
  final double remainingDue;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.customerName,
    required this.totalAmount,
    required this.tax,
    required this.subtotal,
    required this.items,
    required this.customerOldBalance,
    required this.customerNewBalance,
    required this.operatorName,
    required this.amountPaid,
    required this.remainingDue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'customerName': customerName,
        'totalAmount': totalAmount,
        'tax': tax,
        'subtotal': subtotal,
        'items': items.map((e) => e.toJson()).toList(),
        'customerOldBalance': customerOldBalance,
        'customerNewBalance': customerNewBalance,
        'amountPaid': amountPaid,
        'remainingDue': remainingDue,
        'operatorName': operatorName,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        customerName: json['customerName'] as String,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        items: (json['items'] as List<dynamic>)
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customerOldBalance:
            (json['customerOldBalance'] as num?)?.toDouble() ?? 0.0,
        customerNewBalance:
            (json['customerNewBalance'] as num?)?.toDouble() ?? 0.0,
        operatorName: json['operatorName'] as String? ?? 'Unknown',
        amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
        remainingDue: (json['remainingDue'] as num?)?.toDouble() ?? 0.0,
      );
}

class User {
  final String id;
  final String username;
  final String passwordHash;

  User({required this.id, required this.username, required this.passwordHash});

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}

// --- SHARED PREFERENCES SERVICE SIMULATION ---

class SharedPreferencesService {
  static const String _menuKey = 'menu_items';
  static const String _customersKey = 'customer_records';
  static const String _usersKey = 'user_accounts';
  static const String _transactionsKey = 'transaction_history';
  static const String _categoriesKey = 'menu_categories';

  static final Map<String, String> _mockStorage = {};

  List<MenuItem> _getInitialMenuItems() => [
        MenuItem(
            id: 'c1',
            name: "Chicken Curry Meal",
            price: 12.50,
            category: 'Main'),
        MenuItem(
            id: 'v1',
            name: "Vegetable Soup",
            price: 4.00,
            category: 'Appetizer'),
        MenuItem(
            id: 'f1', name: "Fruit Salad", price: 3.50, category: 'Dessert'),
        MenuItem(id: 'i1', name: "Iced Tea", price: 2.00, category: 'Beverage'),
      ];

  List<Customer> _getInitialCustomers() => [
        Customer(
            id: 'u1',
            name: "Ahmed Khan",
            phoneNumber: '923001234567',
            balance: 55.75),
        Customer(
            id: 'u2',
            name: "Sara Ali",
            phoneNumber: '923219876543',
            balance: 0.00),
        Customer(
            id: 'u3',
            name: "Usman Tariq",
            phoneNumber: '923455554444',
            balance: 120.50),
      ];

  List<User> _getInitialUsers() => [
        User(id: 'admin_id', username: 'admin', passwordHash: 'pass123'),
      ];

  List<Category> _getInitialCategories() => [
        Category(id: 'cat1', name: 'Main'),
        Category(id: 'cat2', name: 'Appetizer'),
        Category(id: 'cat3', name: 'Dessert'),
        Category(id: 'cat4', name: 'Beverage'),
      ];

  Future<List<T>> _loadData<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
      List<T> Function() initialData) async {
    String? jsonString = _mockStorage[key];
    if (jsonString == null) {
      final data = initialData();
      await _saveData(key, data);
      return data;
    }
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => fromJson(e)).toList();
  }

  Future<void> _saveData<T>(String key, List<T> data) async {
    final jsonString =
        jsonEncode(data.map((e) => (e as dynamic).toJson()).toList());
    _mockStorage[key] = jsonString;
  }

  Future<List<MenuItem>> loadMenu() async =>
      _loadData(_menuKey, MenuItem.fromJson, _getInitialMenuItems);
  Future<void> saveMenu(List<MenuItem> menu) async => _saveData(_menuKey, menu);

  Future<List<Customer>> loadCustomers() async =>
      _loadData(_customersKey, Customer.fromJson, _getInitialCustomers);
  Future<void> saveCustomers(List<Customer> customers) async =>
      _saveData(_customersKey, customers);

  Future<List<User>> loadUsers() async =>
      _loadData(_usersKey, User.fromJson, _getInitialUsers);
  Future<void> saveUsers(List<User> users) async => _saveData(_usersKey, users);

  Future<List<Transaction>> loadTransactions() async =>
      _loadData(_transactionsKey, Transaction.fromJson, () => []);
  Future<void> saveTransactions(List<Transaction> transactions) async =>
      _saveData(_transactionsKey, transactions);

  Future<List<Category>> loadCategories() async =>
      _loadData(_categoriesKey, Category.fromJson, _getInitialCategories);
  Future<void> saveCategories(List<Category> categories) async =>
      _saveData(_categoriesKey, categories);
}

// --- MAIN APPLICATION SETUP ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Mess POS System',
      debugShowCheckedModeBanner: false, // remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        textTheme: const TextTheme(
          // 👇 customize global font sizes here
          bodyLarge: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 13),
          bodySmall: TextStyle(fontSize: 12),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14),
          titleSmall: TextStyle(fontSize: 12),
        ),
      ),
      home: const MessPosScreen(),
    );
  }
}

// --- AUTHENTICATION SCREEN ---

class _AuthScreen extends StatefulWidget {
  final Function(String username, String password) onLogin;
  final Function(String username, String password) onRegister;

  const _AuthScreen({required this.onLogin, required this.onRegister});

  @override
  State<_AuthScreen> createState() => __AuthScreenState();
}

class __AuthScreenState extends State<_AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  String? _errorMessage;

  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username and password cannot be empty.';
      });
      return;
    }

    String? error;
    if (_isRegistering) {
      error = await widget.onRegister(username, password);
    } else {
      error = await widget.onLogin(username, password);
    }

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_person,
                        size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 30),
                    Text(
                      _isRegistering
                          ? 'STAFF REGISTRATION'
                          : 'POS TERMINAL LOGIN',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                      ),
                      child: Text(
                        _isRegistering ? 'REGISTER ACCOUNT' : 'LOG IN',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegistering = !_isRegistering;
                          _errorMessage = null;
                          _usernameController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(_isRegistering
                          ? 'Already have an account? Login'
                          : 'New staff? Register here'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- MANAGEMENT SCREEN ---

class _ManagementScreen extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<MenuItem> menuItems;
  final List<Customer> customers;
  final List<Transaction> transactions;
  final List<Category> categories;
  final Function(MenuItem item) onMenuItemAdded;
  final Function(List<MenuItem> newMenu) onMenuUpdated;
  final Function(Customer customer) onCustomerAdded;
  final Function(Customer customer) onCustomerUpdated;
  final Function(Category category) onCategoryAdded;
  final Function(List<Category> newCategories) onCategoriesUpdated;
  final VoidCallback onLogout;

  const _ManagementScreen({
    required this.storageService,
    required this.menuItems,
    required this.customers,
    required this.transactions,
    required this.categories,
    required this.onMenuItemAdded,
    required this.onMenuUpdated,
    required this.onCustomerAdded,
    required this.onCustomerUpdated,
    required this.onCategoryAdded,
    required this.onCategoriesUpdated,
    required this.onLogout,
  });

  @override
  State<_ManagementScreen> createState() => __ManagementScreenState();
}

class __ManagementScreenState extends State<_ManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Added a new tab for Profile
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.people_alt), text: 'Customer'),
            Tab(icon: Icon(Icons.analytics), text: 'Sales Report'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BuildMenuManagement(
                storageService: widget.storageService,
                menuItems: widget.menuItems,
                categories: widget.categories,
                onMenuItemAdded: widget.onMenuItemAdded,
                onMenuUpdated: widget.onMenuUpdated,
              ),
              _BuildCategoryManagement(
                storageService: widget.storageService,
                categories: widget.categories,
                onCategoryAdded: widget.onCategoryAdded,
                onCategoriesUpdated: widget.onCategoriesUpdated,
              ),
              _BuildCustomerManagement(
                storageService: widget.storageService,
                customers: widget.customers,
                onCustomerUpdated: widget.onCustomerUpdated,
                onCustomerAdded: widget.onCustomerAdded,
              ),
              _BuildSalesReports(transactions: widget.transactions),
              _ProfileScreen(onLogout: widget.onLogout),
            ],
          ),
        ),
      ],
    );
  }
}

// --- CATEGORY MANAGEMENT SUB-COMPONENT (CRUD) ---

class _ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileScreen({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Profile & Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'LOGOUT',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildCategoryManagement extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<Category> categories;
  final Function(Category category) onCategoryAdded;
  final Function(List<Category> newCategories) onCategoriesUpdated;

  const _BuildCategoryManagement({
    required this.storageService,
    required this.categories,
    required this.onCategoryAdded,
    required this.onCategoriesUpdated,
  });

  @override
  State<_BuildCategoryManagement> createState() =>
      __BuildCategoryManagementState();
}

class __BuildCategoryManagementState extends State<_BuildCategoryManagement> {
  final _nameController = TextEditingController();
  Category? _editingCategory;

  void _resetForm() {
    _nameController.clear();
    setState(() {
      _editingCategory = null;
    });
  }

  void _startEdit(Category category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(context, 'Please enter a valid category name.', Colors.red);
      return;
    }

    if (_editingCategory == null) {
      final newCategory = Category(
        id: Random().nextDouble().toString(),
        name: name,
      );
      widget.onCategoryAdded(newCategory);
      await widget.storageService
          .saveCategories([...widget.categories, newCategory]);
      if (!mounted) return;
      _showMessage(context, 'Category added successfully!', Colors.green);
    } else {
      _editingCategory!.name = name;
      widget.onCategoriesUpdated(widget.categories);
      await widget.storageService.saveCategories(widget.categories);
      if (!mounted) return;
      _showMessage(context, 'Category updated successfully!', Colors.green);
    }
    _resetForm();
  }

  Future<void> _deleteCategory(Category category) async {
    final updatedCategories =
        widget.categories.where((c) => c.id != category.id).toList();
    widget.onCategoriesUpdated(updatedCategories);
    await widget.storageService.saveCategories(updatedCategories);
    if (!mounted) return;
    _showMessage(context, 'Category deleted.', Colors.orange);
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _editingCategory == null ? 'ADD NEW CATEGORY' : 'EDIT CATEGORY',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 250),
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Category Name',
                              prefixIcon: Icon(Icons.category))),
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(
                          _editingCategory == null ? Icons.add : Icons.save,
                          color: Colors.white),
                      label: Text(
                        _editingCategory == null ? 'ADD' : 'SAVE',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editingCategory == null
                            ? Colors.green
                            : Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (_editingCategory != null)
                      OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            const Text('CURRENT CATEGORIES',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: widget.categories.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(category.name[0])),
                    title: Text(category.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _startEdit(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
        ));
  }
}

// --- MENU MANAGEMENT SUB-COMPONENT (CRUD) ---

class _BuildMenuManagement extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<MenuItem> menuItems;
  final List<Category> categories;
  final Function(MenuItem item) onMenuItemAdded;
  final Function(List<MenuItem> newMenu) onMenuUpdated;

  const _BuildMenuManagement({
    required this.storageService,
    required this.menuItems,
    required this.categories,
    required this.onMenuItemAdded,
    required this.onMenuUpdated,
  });

  @override
  State<_BuildMenuManagement> createState() => __BuildMenuManagementState();
}

class __BuildMenuManagementState extends State<_BuildMenuManagement> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  MenuItem? _editingItem;
  final _searchController = TextEditingController();
  List<MenuItem> _filteredMenuItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.name;
    }
    _filteredMenuItems = widget.menuItems; // Initialize with all items
    _searchController.addListener(_filterMenuItems);
  }

  @override
  void didUpdateWidget(covariant _BuildMenuManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menuItems != widget.menuItems ||
        oldWidget.categories != widget.categories) {
      // Re-filter if the underlying data changes
      _filterMenuItems();
    }
    // Ensure selected category is still valid if categories change
    if (!widget.categories.any((cat) => cat.name == _selectedCategory)) {
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first.name : null;
    }
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    setState(() {
      _editingItem = null;
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first.name : null;
    });
    _filterMenuItems(); // Re-filter after form reset
  }

  void _filterMenuItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenuItems = widget.menuItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.price.toString().contains(query);
      }).toList();
    });
  }

  void _startEdit(MenuItem item) {
    setState(() {
      _editingItem = item;
      _nameController.text = item.name;
      _priceController.text = item.price.toString();
      _selectedCategory = item.category;
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final category = _selectedCategory;

    if (name.isEmpty || price <= 0 || category == null || category.isEmpty) {
      _showMessage(context,
          'Please enter valid name, price, and select a category.', Colors.red);
      return;
    }

    if (_editingItem == null) {
      final newItem = MenuItem(
        id: Random().nextDouble().toString(),
        name: name,
        price: price,
        category: category,
      );
      widget.onMenuItemAdded(newItem);
      await widget.storageService.saveMenu([...widget.menuItems, newItem]);
      if (!mounted) return;
      _showMessage(context, 'Menu Item added successfully!', Colors.green);
    } else {
      _editingItem!.name = name;
      _editingItem!.price = price;
      _editingItem!.category = category;
      widget.onMenuUpdated(widget.menuItems);
      await widget.storageService.saveMenu(widget.menuItems);
      if (!mounted) return;
      _showMessage(context, 'Menu Item updated successfully!', Colors.green);
    }
    _resetForm();
  }

  Future<void> _deleteItem(MenuItem item) async {
    final updatedMenu = widget.menuItems.where((i) => i.id != item.id).toList();
    widget.onMenuUpdated(updatedMenu);
    await widget.storageService.saveMenu(updatedMenu);
    if (!mounted) return;
    _showMessage(context, 'Item deleted.', Colors.orange);
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_editingItem == null ? 'ADD NEW MENU ITEM' : 'EDIT MENU ITEM',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.food_bank))),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                            prefixIcon: Icon(Icons.attach_money)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                          ),
                          value: _selectedCategory,
                          items: widget.categories.map((Category cat) {
                            return DropdownMenuItem<String>(
                              value: cat.name,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a category' : null),
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(_editingItem == null ? Icons.add : Icons.save,
                          color: Colors.white),
                      label: Text(
                        _editingItem == null ? 'ADD' : 'SAVE',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _editingItem == null ? Colors.green : Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (_editingItem != null)
                      OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Menu Items (Name, Category, Price)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterMenuItems(),
            ),
            const SizedBox(height: 10),
            const Text('CURRENT MENU ITEMS',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: _filteredMenuItems.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final item = _filteredMenuItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(item.category[0])),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Category: ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green)),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _startEdit(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
        ));
  }
}

// --- CUSTOMER MANAGEMENT SUB-COMPONENT ---

class _BuildCustomerManagement extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<Customer> customers;
  final Function(Customer customer) onCustomerAdded;
  final Function(Customer customer) onCustomerUpdated;

  const _BuildCustomerManagement({
    required this.storageService,
    required this.customers,
    required this.onCustomerAdded,
    required this.onCustomerUpdated,
  });

  @override
  State<_BuildCustomerManagement> createState() =>
      __BuildCustomerManagementState();
}

class __BuildCustomerManagementState extends State<_BuildCustomerManagement> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');
  final _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  Future<void> _addCustomer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final initialBalance = double.tryParse(_balanceController.text) ?? 0.0;

    // 1️⃣ Safe to use context here (before any await)
    if (name.isEmpty || phone.isEmpty) {
      if (mounted) {
        _showMessage(
          context,
          'Please enter valid name and phone number.',
          Colors.red,
        );
      }
      return;
    }

    final newCustomer = Customer(
      id: Random().nextDouble().toString(),
      name: name,
      phoneNumber: phone,
      balance: initialBalance,
    );

    // 2️⃣ Notify parent widget
    widget.onCustomerAdded(newCustomer);

    // 3️⃣ Save asynchronously
    await widget.storageService.saveCustomers([
      ...widget.customers,
      newCustomer,
    ]);

    // 4️⃣ After an async call, always check mounted before using context again
    if (!mounted) return;

    // 5️⃣ Update UI safely
    _nameController.clear();
    _phoneController.clear();
    _balanceController.text = '0.00';

    _showMessage(
      context,
      'Customer registered successfully!',
      Colors.green,
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _searchController.addListener(_filterCustomers);
  }

  @override
  void didUpdateWidget(covariant _BuildCustomerManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customers != widget.customers) {
      _filterCustomers(); // Re-filter if the underlying data changes
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = widget.customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phoneNumber.toLowerCase().contains(query) ||
            customer.balance.toStringAsFixed(2).contains(query);
      }).toList();
    });
  }

  Future<void> _payDues(Customer customer) async {
    final payAmountController = TextEditingController();
    double? paidAmount;

    await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Pay Dues for ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Balance: \$${customer.balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: payAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Pay',
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = double.tryParse(payAmountController.text);
              if (input != null && input > 0 && input <= customer.balance) {
                paidAmount = input;
                Navigator.pop(dialogContext, paidAmount);
              } else if (input != null && input > customer.balance) {
                _showMessage(dialogContext,
                    'Amount paid cannot exceed pending dues.', Colors.red);
              } else {
                _showMessage(
                    dialogContext, 'Please enter a valid amount.', Colors.red);
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );

    if (paidAmount != null && mounted) {
      final updatedBalance = customer.balance - paidAmount!;
      customer.balance = double.parse(updatedBalance.toStringAsFixed(2));

      widget.onCustomerUpdated(customer);
      await widget.storageService.saveCustomers(widget.customers);

      if (mounted) {
        _showMessage(
          context,
          'Dues of \$${paidAmount.toString()} paid for ${customer.name}. '
          'New balance: \$${customer.balance.toStringAsFixed(2)}',
          Colors.green,
        );
      }
    }
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('REGISTER NEW CUSTOMER',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              prefixIcon: Icon(Icons.person_add))),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone)),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 180),
                      child: TextField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                            labelText: 'Initial Balance (\$)',
                            prefixIcon: Icon(Icons.account_balance_wallet)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addCustomer,
                      icon: const Icon(Icons.person_add_alt_1,
                          color: Colors.white),
                      label: const Text(
                        'REGISTER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Customers (Name, Phone, Balance)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterCustomers(),
            ),
            const SizedBox(height: 10),
            const Text('REGISTERED CUSTOMERS',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: _filteredCustomers.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(customer.name[0])),
                    title: Text(customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Phone: ${customer.phoneNumber}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Balance: \$${customer.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: customer.balance > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        if (customer.balance > 0)
                          IconButton(
                            icon: const Icon(Icons.payment, color: Colors.blue),
                            onPressed: () => _payDues(customer),
                            tooltip: 'Pay Dues',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
        ));
  }
}

// --- SALES REPORTS SUB-COMPONENT (Total Sale and Receipts) --- (Now Stateful)

class _BuildSalesReports extends StatefulWidget {
  final List<Transaction> transactions;

  const _BuildSalesReports({required this.transactions});

  @override
  State<_BuildSalesReports> createState() => _BuildSalesReportsState();
}

class _BuildSalesReportsState extends State<_BuildSalesReports> {
  final TextEditingController _transactionSearchController =
      TextEditingController();
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = widget.transactions;
    _transactionSearchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _transactionSearchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BuildSalesReports oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _filterTransactions(); // Re-filter if the underlying data changes
    }
  }

  void _filterTransactions() {
    final query = _transactionSearchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = widget.transactions.where((t) {
        return t.customerName.toLowerCase().contains(query) ||
            t.id.toLowerCase().contains(query) ||
            t.operatorName.toLowerCase().contains(query) ||
            t.items.any((item) => item.name.toLowerCase().contains(query));
      }).toList();
    });
  }

  double get _totalSale =>
      _filteredTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('TOTAL REVENUE (ALL SALES)',
                          style: TextStyle(
                              // Reduced font size
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${_totalSale.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 30, // Reduced font size
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            TextField(
              controller: _transactionSearchController,
              decoration: const InputDecoration(
                labelText: 'Search Transactions (Customer, ID, Operator, Item)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterTransactions(),
            ),
            const SizedBox(height: 10),
            const Text('TRANSACTION HISTORY (RECEIPTS)',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            widget.transactions.isEmpty
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No transactions recorded yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ))
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    shrinkWrap: true,
                    primary: false, // Important for nested scrolling
                    itemBuilder: (context, index) {
                      final t = _filteredTransactions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading:
                              CircleAvatar(child: Text((index + 1).toString())),
                          title: Text('Sale to: ${t.customerName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'ID: ${t.id.substring(0, 8)} | Date: ${t.timestamp.toString().substring(0, 16)}'),
                          trailing: Text(
                            '\$${t.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.indigo),
                          ),
                          onTap: () => _showReceiptDialog(context, t),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, Transaction t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            children: [
              const Text('TRANSACTION RECEIPT',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(t.id.substring(0, 15),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                _receiptRow('Customer', t.customerName),
                _receiptRow('Operator', t.operatorName),
                _receiptRow('Date', t.timestamp.toString().substring(0, 16)),
                const Divider(),
                const Text('Items:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...t.items.map((item) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.name} x ${item.quantity}'),
                          Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const Divider(color: Colors.black),
                _receiptRow('Subtotal', '\$${t.subtotal.toStringAsFixed(2)}'),
                _receiptRow('Tax (8%)', '\$${t.tax.toStringAsFixed(2)}'),
                _receiptRow(
                    'Total Bill', '\$${t.totalAmount.toStringAsFixed(2)}',
                    isTotal: true),
                _receiptRow(
                    'Amount Paid', '\$${t.amountPaid.toStringAsFixed(2)}',
                    isTotal: true),
                _receiptRow(
                    'Remaining Due', '\$${t.remainingDue.toStringAsFixed(2)}',
                    isTotal: true),
                const Divider(color: Colors.black),
                _receiptRow('Old Balance',
                    '\$${t.customerOldBalance.toStringAsFixed(2)}'),
                _receiptRow('New Balance',
                    '\$${t.customerNewBalance.toStringAsFixed(2)}',
                    isTotal: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14)),
        ],
      ),
    );
  }
}

// --- POS SCREEN (MAIN WIDGET) ---

class MessPosScreen extends StatefulWidget {
  const MessPosScreen({super.key});

  @override
  State<MessPosScreen> createState() => _MessPosScreenState();
}

class _MessPosScreenState extends State<MessPosScreen> {
  final SharedPreferencesService _storageService = SharedPreferencesService();

  User? _currentUser;
  bool _isLoggedIn = false;

  List<MenuItem> _menuItems = [];
  List<Customer> _customers = [];
  List<Category> _categories = [];
  List<Transaction> _transactions = [];
  List<MenuItem> _cart = [];
  Customer _selectedCustomer = Customer.walkIn;
  final TextEditingController _menuSearchController =
      TextEditingController(); // For POS menu search
  List<MenuItem> _filteredPosMenuItems = []; // For POS menu search

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _menuSearchController.addListener(_filterPosMenuItems);
  }

  Future<void> _loadData() async {
    final menu = await _storageService.loadMenu();
    final customers = await _storageService.loadCustomers();
    final transactions = await _storageService.loadTransactions();
    final categories = await _storageService.loadCategories();

    setState(() {
      _menuItems = menu;
      _customers = customers;
      _transactions = transactions;
      _categories = categories;
      _isLoading = false;
      _filterPosMenuItems(); // Initial filter for POS menu after loading data
    });
  }

  // --- AUTH/MANAGEMENT LOGIC (Updated to use callbacks for state updates) ---

  Future<String?> _login(String username, String password) async {
    final users = await _storageService.loadUsers();
    try {
      final user = users.firstWhere(
          (u) => u.username == username && u.passwordHash == password);
      setState(() {
        _currentUser = user;
        _isLoggedIn = true;
      });
      return null;
    } catch (e) {
      return 'Invalid username or password.';
    }
  }

  Future<String?> _register(String username, String password) async {
    final users = await _storageService.loadUsers();
    if (users.any((u) => u.username == username)) {
      return 'User already exists.';
    }

    final newUser = User(
        id: Random().nextDouble().toString(),
        username: username,
        passwordHash: password);
    users.add(newUser);
    await _storageService.saveUsers(users);

    setState(() {
      _currentUser = newUser;
      _isLoggedIn = true;
    });
    return null;
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
      _cart = [];
      _selectedCustomer = Customer.walkIn;
    });
  }

  void _addMenuItem(MenuItem item) {
    setState(() {
      _menuItems.add(item);
    });
  }

  void _updateMenu(List<MenuItem> newMenu) {
    setState(() {
      _menuItems = newMenu;
      _filterPosMenuItems(); // Re-filter POS menu when menu items are updated
    });
  }

  void _addCustomer(Customer customer) {
    setState(() {
      _customers.add(customer);
      _selectedCustomer = customer;
    });
  }

  void _updateCustomer(Customer updatedCustomer) {
    setState(() {
      final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }
      if (_selectedCustomer.id == updatedCustomer.id) {
        _selectedCustomer = updatedCustomer;
      }
    });
  }

  void _addCategory(Category category) {
    setState(() {
      _categories.add(category);
    });
  }

  void _updateCategories(List<Category> newCategories) {
    setState(() {
      _categories = newCategories;
    });
  }

  void _filterPosMenuItems() {
    final query = _menuSearchController.text.toLowerCase();
    setState(() {
      _filteredPosMenuItems = _menuItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.category
                .toLowerCase()
                .contains(query); // Search by name or category
      }).toList();
    });
  }

  // --- BUSINESS LOGIC (POS) ---

  void _addToCart(MenuItem item) {
    setState(() {
      final index = _cart.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(MenuItem(
          id: item.id,
          name: item.name,
          price: item.price,
          category: item.category,
          quantity: 1,
        ));
      }
    });
  }

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final index = _cart.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _cart[index].quantity += delta;
        if (_cart[index].quantity <= 0) {
          _cart.removeAt(index);
        }
      }
    });
  }

  double get _subtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  double get _taxRate => 0.08;
  double get _tax => double.parse((_subtotal * _taxRate).toStringAsFixed(2));
  double get _transactionTotal =>
      double.parse((_subtotal + _tax).toStringAsFixed(2));

  Future<void> _handleCheckout() async {
    // 1️⃣ Check cart first — safe (no async yet)
    if (_cart.isEmpty) {
      if (mounted) {
        _showMessage(context, 'Cart is empty!', Colors.red);
      }
      return;
    }

    // 2️⃣ Await async dialog — don't use context after await without mounted check
    final paidAmount = await _showPaymentDialog(context, _transactionTotal);
    if (paidAmount == null) return;

    // 3️⃣ Check operator login (safe, no async yet)
    if (_currentUser == null) {
      if (mounted) {
        _showMessage(context, 'Error: Operator not logged in.', Colors.red);
      }
      return;
    }

    // 4️⃣ Calculate balances
    final newAmount = _transactionTotal;
    double oldBalance = _selectedCustomer.balance;
    double newBalance = oldBalance + (newAmount - paidAmount);

    // 5️⃣ Update customer data (with async)
    if (_selectedCustomer.id != 'walk_in') {
      final custIndex =
          _customers.indexWhere((c) => c.id == _selectedCustomer.id);

      if (custIndex != -1) {
        oldBalance = _customers[custIndex].balance;
        newBalance = double.parse(
          (oldBalance + (newAmount - paidAmount)).toStringAsFixed(2),
        );

        setState(() {
          _customers[custIndex].balance = newBalance;
          _selectedCustomer = _customers[custIndex];
        });

        await _storageService.saveCustomers(_customers);
      }
    }

    // 6️⃣ Save transaction (async)
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      timestamp: DateTime.now(),
      customerName: _selectedCustomer.name,
      totalAmount: newAmount,
      tax: _tax,
      subtotal: _subtotal,
      items: _cart
          .map((i) => MenuItem(
                id: i.id,
                name: i.name,
                price: i.price,
                category: i.category,
                quantity: i.quantity,
              ))
          .toList(),
      customerOldBalance: oldBalance,
      customerNewBalance: newBalance,
      operatorName: _currentUser!.username,
      amountPaid: paidAmount,
      remainingDue: newAmount - paidAmount,
    );

    _transactions.insert(0, newTransaction);
    await _storageService.saveTransactions(_transactions);

    // 7️⃣ Always check mounted before using context after awaits
    if (!mounted) return;

    _showMessage(
      context,
      'Transaction Complete! Total Sale: \$${newAmount.toStringAsFixed(2)}',
      Colors.green,
    );

    // 8️⃣ Clear cart safely
    setState(() {
      _cart = [];
    });
  }

  Future<double?> _showPaymentDialog(
      BuildContext context, double totalAmount) async {
    final payAmountController =
        TextEditingController(text: totalAmount.toStringAsFixed(2));
    double? paidAmount;

    await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Payment Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Bill: \$${totalAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: payAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = double.tryParse(payAmountController.text);
              if (input != null && input >= 0 && input <= totalAmount) {
                paidAmount = input;
                Navigator.pop(dialogContext, paidAmount);
              } else {
                _showMessage(
                    dialogContext,
                    'Please enter a valid amount (cannot exceed total bill).',
                    Colors.red);
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
    return paidAmount;
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Register New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 10),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                final newCustomer = Customer(
                  id: Random().nextDouble().toString(),
                  name: name,
                  phoneNumber: phone,
                  balance: 0.00,
                );
                _addCustomer(newCustomer);
                await _storageService
                    .saveCustomers([..._customers, newCustomer]);

                if (!dialogContext.mounted) return;
                _showMessage(dialogContext,
                    'Customer $name registered and selected!', Colors.blue);
                Navigator.pop(dialogContext);
              } else {
                _showMessage(
                    dialogContext, 'Please fill out both fields.', Colors.red);
              }
            },
            child: const Text('Register & Select'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Loading Hotel POS System...')
            ],
          ),
        ),
      );
    }

    if (!_isLoggedIn || _currentUser == null) {
      return _AuthScreen(onLogin: _login, onRegister: _register);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Flexible(
            // Make title flexible to prevent overflow
            child: Text(
                'Hotel Mess POS Terminal | Logged in as ${_currentUser!.username}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          actions: [
            IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Logout'),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.point_of_sale), text: 'Sales Terminal'),
              Tab(icon: Icon(Icons.settings), text: 'Management'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 800) {
                  // Small screen layout with DraggableScrollableSheet for the cart
                  return Stack(
                    children: [
                      _buildMenuPanel(), // Menu panel takes up the whole background
                      DraggableScrollableSheet(
                        initialChildSize: 0.35, // Start with 35% of the screen
                        minChildSize: 0.15, // Can be minimized to 15%
                        maxChildSize: 0.8, // Can be expanded to 80%
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return _buildCartPanel(
                              scrollController: scrollController);
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildMenuPanel()),
                      Expanded(flex: 2, child: _buildCartPanel()),
                    ],
                  );
                }
              },
            ),
            _ManagementScreen(
              storageService: _storageService,
              menuItems: _menuItems,
              customers: _customers,
              transactions: _transactions,
              categories: _categories,
              onCustomerUpdated: _updateCustomer,
              onMenuItemAdded: _addMenuItem,
              onMenuUpdated: _updateMenu,
              onCustomerAdded: _addCustomer,
              onCategoryAdded: _addCategory,
              onCategoriesUpdated: _updateCategories,
              onLogout: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Customer>(
                  decoration: const InputDecoration(
                    labelText: 'Select Customer',
                    prefixIcon: Icon(Icons.person_pin),
                  ),
                  value: _selectedCustomer,
                  items: [
                    DropdownMenuItem(
                        value: Customer.walkIn,
                        child: Text(Customer.walkIn.name)),
                    ..._customers.map((Customer c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                            '${c.name} (Bal: \$${c.balance.toStringAsFixed(2)})'),
                      );
                    }),
                  ],
                  onChanged: (Customer? newValue) {
                    setState(() {
                      _selectedCustomer = newValue ?? Customer.walkIn;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text('New',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(80, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _menuSearchController,
            decoration: const InputDecoration(
              labelText: 'Search Menu Items',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            onChanged: (_) => _filterPosMenuItems(), // Trigger filter on change
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredPosMenuItems.length, // Use filtered list
            itemBuilder: (context, index) {
              final item = _filteredPosMenuItems[index]; // Use filtered list
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.category,
                      style: TextStyle(color: Colors.grey[600])),
                  trailing: Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green),
                  ),
                  onTap: () => _addToCart(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartPanel({ScrollController? scrollController}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Text(
            'ORDER FOR: ${_selectedCustomer.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo),
          ),
          if (_selectedCustomer.id != 'walk_in')
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Current Balance: \$${(_selectedCustomer.balance).toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ),
          const Divider(height: 20),
          if (_cart.isEmpty)
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text('CART IS EMPTY',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ))
          else
            ..._cart.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => _updateQuantity(item.id, -1)),
                      Text(item.quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.green),
                          onPressed: () => _updateQuantity(item.id, 1)),
                      const SizedBox(width: 8),
                      Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                )),
          const Divider(),
          _buildSummaryRow('Subtotal', _subtotal, Colors.black87),
          _buildSummaryRow('Tax (8%)', _tax, Colors.black87),
          _buildSummaryRow(
              'NEW AMOUNT (TOTAL)', _transactionTotal, Colors.indigo),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _handleCheckout,
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: Text(
              'CHECKOUT (\$${_transactionTotal.toStringAsFixed(2)})',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    bool isTotal = title.contains('TOTAL');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14)),
        ],
      ),
    );
  }
}
