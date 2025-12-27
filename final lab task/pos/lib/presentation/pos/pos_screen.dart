import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/sales_repository.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<CartItem> _cart = [];
  final ProductRepository _productRepo = ProductRepository();
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActualData();
  }

  void _loadActualData() async {
    try {
      final data = await _productRepo.fetchAllProducts(); 
      setState(() {
        _products = data;
        _filteredProducts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                        p.sku.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(ProductModel product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) _cart.removeAt(index);
    });
  }

  double _calculateTotal() => _cart.fold(0, (sum, item) => sum + item.subtotal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Responsive(
            mobile: _buildProductSection(context),
            tablet: Row(
              children: [
                Expanded(flex: 2, child: _buildProductSection(context)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildCartSidebar()),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(flex: 3, child: _buildProductSection(context)),
                const VerticalDivider(width: 1),
                SizedBox(width: 400, child: _buildCartSidebar()),
              ],
            ),
          ),
      floatingActionButton: Responsive.isMobile(context) && _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showMobileCart(),
              label: Text("View Bill (Rs. ${_calculateTotal()})"),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }

  Widget _buildProductSection(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        _buildSearchHeader(),
        Expanded(
          child: _filteredProducts.isEmpty 
          ? const Center(child: Text("No products found"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width > 1200 ? 4 : (width > 800 ? 3 : 2),
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
            ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchCtrl,
        onChanged: _filterProducts,
        decoration: InputDecoration(
          hintText: "Search Product or SKU...",
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          filled: true,
          fillColor: const Color(0xFFF1F3F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: InkWell(
        onTap: () => _addToCart(p),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(p.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("Rs. ${p.sellingPrice}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  Text("Stock: ${p.stockQuantity}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSidebar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Current Bill", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: _cart.isEmpty 
              ? const Center(child: Text("Cart is empty"))
              : ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) => _buildCartListTile(_cart[index], index),
                ),
          ),
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildCartListTile(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => setState(() => _cart.removeAt(index)),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _qtyBtn(Icons.remove, () => _updateQuantity(index, -1)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("${item.quantity}")),
                  _qtyBtn(Icons.add, () => _updateQuantity(index, 1)),
                ],
              ),
              Text("Rs. ${item.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Payable", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text("Rs. ${_calculateTotal().toStringAsFixed(2)}", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 20),
          // Inside POSScreen _buildSummarySection
ElevatedButton(
  onPressed: _cart.isEmpty ? null : () async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await SalesRepository().processCheckout(
      cart: _cart,
      customerName: "Walking Customer",
    );

    if (mounted) Navigator.pop(context); // Remove loading indicator

    if (success) {
      setState(() {
        _cart.clear(); // Empty the cart
      });
      _loadActualData(); // Refresh product list to see updated stock levels
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale Completed Successfully!"), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkout Failed!"), backgroundColor: Colors.red)
      );
    }
  },
  child: const Text("PROCEED TO CHECKOUT"),
),
        ],
      ),
    );
  }

  void _showMobileCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: _buildCartSidebar(),
      ),
    );
  }
}