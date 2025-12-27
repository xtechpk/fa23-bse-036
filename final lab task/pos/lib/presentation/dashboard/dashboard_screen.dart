import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder to get exact pixel constraints of the parent
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean professional grey
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                
                // 1. ANALYTICS CARDS SECTION
                // This grid automatically decides how many cards fit based on width
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300, // Cards won't grow bigger than 300px
                    mainAxisExtent: 180,    // Fixed height for consistency
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    return _buildAnalysisCard(index);
                  },
                ),
                
                const SizedBox(height: 32),
                
                // 2. MAIN CONTENT SECTION (Chart + Recent Activity)
                // Switches from Column (Mobile) to Row (Desktop)
                Responsive(
                  mobile: Column(
                    children: [
                      _buildMainChart(constraints.maxWidth),
                      const SizedBox(height: 24),
                      _buildRecentActivity(),
                    ],
                  ),
                  desktop: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildMainChart(constraints.maxWidth)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentActivity()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Business Overview", 
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
        Text("Real-time data from your Sweet Shop", 
          style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnalysisCard(int index) {
    final List<Map<String, dynamic>> data = [
      {"title": "Total Revenue", "value": "Rs. 125,430", "icon": Icons.payments, "color": Colors.blue},
      {"title": "Today's Sales", "value": "Rs. 12,200", "icon": Icons.shopping_bag, "color": Colors.green},
      {"title": "Stock Alert", "value": "5 Items Low", "icon": Icons.inventory_2, "color": Colors.orange},
      {"title": "Pending Orders", "value": "14", "icon": Icons.timer, "color": Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: data[index]['color'].withOpacity(0.1),
            child: Icon(data[index]['icon'], color: data[index]['color']),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data[index]['title'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(data[index]['value'], 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart(double width) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C1E), // Dark modern theme for charts
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales Performance", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Center(child: Icon(Icons.show_chart, size: 80, color: Colors.blueAccent)),
          Spacer(),
          Text("Last 7 days growth: +12.5%", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Walk-in Customer", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("Cake Order #122", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text("Rs. ${250 * (i + 1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}