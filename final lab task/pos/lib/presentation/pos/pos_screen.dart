import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/product_model.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../core/utils/responsive.dart';
import '../widgets/three_d_card.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<CartItem> _cart = [];
  final _productRepo = ProductRepository();
  final _salesRepo = SalesRepository();
  
  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayProducts = [];
  List<CategoryModel> _categories = [];
  
  String _selectedCategory = "All";
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() { 
    super.initState(); 
    _loadInitialData(); 
  }

  // Refreshes data from SQLite
  void _loadInitialData() async {
    final products = await _productRepo.fetchAllProducts();
    final categories = await _productRepo.fetchAllCategories();
    setState(() {
      _allProducts = products;
      _displayProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _filterProducts(String query, String category) {
    setState(() {
      _displayProducts = _allProducts.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(query.toLowerCase()) || 
                              p.sku.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = category == "All" || p.category == category;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _addToCart(ProductModel p) {
    // 1. Check current stock availability
    final cartIndex = _cart.indexWhere((item) => item.product.id == p.id);
    int currentInCart = cartIndex != -1 ? _cart[cartIndex].quantity : 0;

    if (p.stockQuantity > currentInCart) {
      setState(() {
        if (cartIndex != -1) {
          _cart[cartIndex].quantity++;
        } else {
          _cart.add(CartItem(product: p, quantity: 1));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock!"), backgroundColor: Colors.orange),
      );
    }
  }

  void _updateQty(int i, int delta) {
    setState(() {
      int newQty = _cart[i].quantity + delta;
      
      // Prevent exceeding stock during manual update
      if (newQty > _cart[i].product.stockQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insufficient Stock!"), backgroundColor: Colors.red),
        );
        return;
      }

      _cart[i].quantity = newQty;
      if (_cart[i].quantity <= 0) _cart.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Responsive(
            mobile: _buildProductSide(),
            tablet: Row(children: [
              Expanded(flex: 2, child: _buildProductSide()), 
              const VerticalDivider(width: 1), 
              Expanded(child: _buildCartSide())
            ]),
            desktop: Row(children: [
              Expanded(flex: 3, child: _buildProductSide()), 
              const VerticalDivider(width: 1), 
              SizedBox(width: 400, child: _buildCartSide())
            ]),
          ),
      // Mobile Cart Trigger
      floatingActionButton: Responsive.isMobile(context) && _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showMobileCart(),
              label: Text("View Bill (${_cart.length})"),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }

  Widget _buildProductSide() {
    return Column(children: [
      _buildTopSearchBar(),
      _buildCategorySelector(),
      Expanded(
        child: _displayProducts.isEmpty 
          ? const Center(child: Text("No products found"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220, 
                childAspectRatio: 0.75, 
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12
              ),
              itemCount: _displayProducts.length,
              itemBuilder: (context, i) => _buildProductCard(_displayProducts[i], i),
            ),
      )
    ]);
  }

  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search items or scan SKU...", 
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                _searchController.clear();
                _filterProducts("", _selectedCategory);
              }) 
            : null,
          filled: true, 
          fillColor: Colors.white, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
        ),
        onChanged: (q) => _filterProducts(q, _selectedCategory),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip("All"),
          ..._categories.map((c) => _buildCategoryChip(c.name)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        onSelected: (val) {
          setState(() => _selectedCategory = label);
          _filterProducts(_searchController.text, label);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel p, int index) {
    bool isLowStock = p.stockQuantity <= p.lowStockLimit;
    return EntranceFader(
      delay: Duration(milliseconds: 50 * (index % 10)),
      child: ThreeDCard(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      onTap: () => _addToCart(p),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100], 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15))
              ),
              child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), 
                    child: Image.network(
                      p.imageUrl!, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ) 
                : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text("Rs. ${p.sellingPrice}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              Text("Stock: ${p.stockQuantity}", style: TextStyle(fontSize: 11, color: isLowStock ? Colors.red : Colors.grey)),
            ]),
          )
        ]),
      ),
      );
  }

  Widget _buildCartSide() {
    double total = _cart.fold(0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));
    return Container(
      color: Colors.white,
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20), 
          child: Text("Current Bill", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
        ),
        const Divider(height: 1),
        Expanded(
          child: _cart.isEmpty 
            ? const Center(child: Text("Your cart is empty"))
            : ListView.builder(
                itemCount: _cart.length,
                itemBuilder: (context, i) => _buildCartListTile(i),
              ),
        ),
        _buildCheckoutFooter(total),
      ]),
    );
  }

  Widget _buildCartListTile(int i) {
    final item = _cart[i];
    return EntranceFader(
      offset: const Offset(20, 0),
      child: ThreeDCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Row(children: [
          _qtyAction(Icons.remove, () => _updateQty(i, -1)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("${item.quantity}")),
          _qtyAction(Icons.add, () => _updateQty(i, 1)),
        ]),
        trailing: Text("Rs. ${(item.product.sellingPrice * item.quantity).toStringAsFixed(2)}", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      ),
    );
  }

  Widget _qtyAction(IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap, 
      child: Container(
        padding: const EdgeInsets.all(4), 
        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(6)), 
        child: Icon(icon, size: 16, color: Colors.white)
      )
    );
  }

  Widget _buildCheckoutFooter(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Total Amount", style: TextStyle(fontSize: 16, color: Colors.grey)), 
          Text("Rs. ${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent))
        ]),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _cart.isEmpty ? null : () async {
            // Show loading
            showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));

            final saleId = await _salesRepo.processCheckout(cart: _cart, customerName: "Walking Customer");

            Navigator.pop(context); // Close loading

            if (saleId != null) {
              final double total = _cart.fold(0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));

              // Generate and share receipt PDF
              try {
                await _generateReceiptPdf(saleId, List.from(_cart), total);
              } catch (e) {
                // ignore pdf error, continue
              }

              setState(() => _cart.clear());
              _loadInitialData(); // Crucial: Refresh stock immediately
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Checkout Successful!"), backgroundColor: Colors.green)
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checkout failed"), backgroundColor: Colors.red));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: const Text("FINISH SALE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        )
      ]),
    );
  }

  Future<void> _generateReceiptPdf(String saleId, List<CartItem> cart, double total) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    pdf.addPage(pw.Page(build: (context) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('SMART POS PRO', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Sale ID: $saleId'),
        pw.Text('Date: ${DateFormat.yMd().add_jm().format(now)}'),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: ['Item', 'Qty', 'Price', 'Total'],
          data: cart.map((c) => [c.product.name, c.quantity.toString(), c.product.sellingPrice.toStringAsFixed(2), (c.product.sellingPrice * c.quantity).toStringAsFixed(2)]).toList(),
        ),
        pw.Divider(),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Total: Rs ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
      ]);
    }));

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'receipt_$saleId.pdf');
  }

  void _showMobileCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildCartSide(),
      ),
    );
  }
}