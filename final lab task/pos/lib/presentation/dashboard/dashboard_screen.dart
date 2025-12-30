import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/sales_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/utils/responsive.dart';
import '../widgets/three_d_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SalesRepository _salesRepo = SalesRepository();
  final ProductRepository _productRepo = ProductRepository();

  String _selectedFilter = "Daily"; 
  DateTimeRange _customRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  double _totalRevenue = 0;
  double _totalProfit = 0;
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _filteredSales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    DateTime start;
    DateTime end = DateTime.now();

    if (_selectedFilter == "Daily") {
      start = DateTime(end.year, end.month, end.day);
    } else if (_selectedFilter == "Weekly") {
      start = end.subtract(const Duration(days: 7));
    } else if (_selectedFilter == "Monthly") {
      start = DateTime(end.year, end.month, 1);
    } else {
      start = _customRange.start;
      end = _customRange.end;
    }

    final sales = await _salesRepo.fetchSalesByRange(start, end);
    final products = await _productRepo.fetchAllProducts();

    double revenue = 0;
    double profit = 0;
    for (var s in sales) {
      revenue += (s['total_amount'] as num).toDouble();
      profit += (s['total_profit'] as num).toDouble();
    }

    setState(() {
      _totalRevenue = revenue;
      _totalProfit = profit;
      _lowStockCount = products.where((p) => p.stockQuantity <= p.lowStockLimit).length;
      _filteredSales = sales;
      _isLoading = false;
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _selectedFilter = "Custom";
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E), // Deep luxury background
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFilterRow(),
                    const SizedBox(height: 25),
                    _buildStatGrid(),
                    const SizedBox(height: 35),
                    _buildSectionHeader("Recent Transactions"),
                    const SizedBox(height: 15),
                    _buildSalesList(),
                  ]),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: const Color(0xFF0F0F1E),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: const Text(
          "Analytics Overview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF1E1E2C), Color(0xFF0F0F1E)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _fetchData,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...["Daily", "Weekly", "Monthly"].map((filter) {
            bool isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _fetchData();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected 
                    ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)])
                    : null,
                  color: isSelected ? null : const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 10)] : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: _pickCustomDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedFilter == "Custom" ? const Color(0xFF6C63FF) : const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    _selectedFilter == "Custom" 
                        ? "${DateFormat('Md').format(_customRange.start)} - ${DateFormat('Md').format(_customRange.end)}" 
                        : "Custom",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        EntranceFader(delay: const Duration(milliseconds: 0), child: _sexyStatCard("Revenue", "Rs. ${_totalRevenue.toStringAsFixed(0)}", const Color(0xFF00D2FF), Icons.auto_graph)),
        EntranceFader(delay: const Duration(milliseconds: 100), child: _sexyStatCard("Profit", "Rs. ${_totalProfit.toStringAsFixed(0)}", const Color(0xFF00FF87), Icons.insights)),
        EntranceFader(delay: const Duration(milliseconds: 200), child: _sexyStatCard("Sales", "${_filteredSales.length}", const Color(0xFFFFB300), Icons.shopping_bag_rounded)),
        EntranceFader(delay: const Duration(milliseconds: 300), child: _sexyStatCard("Low Stock", "$_lowStockCount", const Color(0xFFFF5252), Icons.warning_amber_rounded)),
      ],
    );
  }

  Widget _sexyStatCard(String title, String value, Color color, IconData icon) {
    return ThreeDCard(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E2C),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("See All", style: TextStyle(color: Color(0xFF6C63FF))),
        )
      ],
    );
  }

  Widget _buildSalesList() {
    if (_filteredSales.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("No data found for this period", style: TextStyle(color: Colors.white38)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSales.length,
      itemBuilder: (context, i) {
        final sale = _filteredSales[i];
        return EntranceFader(
          delay: Duration(milliseconds: i * 50),
          child: ThreeDCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF6C63FF)),
            ),
            title: Text(
              sale['customer_name'] ?? "Walking Customer",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd MMM, hh:mm a').format(DateTime.parse(sale['date'])),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Text(
              "Rs. ${sale['total_amount']}",
              style: const TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ),
        );
      },
    );
  }
}