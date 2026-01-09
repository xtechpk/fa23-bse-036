import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/product_repository.dart';

class CheckoutScreen extends StatefulWidget {
  final List<ProductModel> cartItems;
  final VoidCallback onCheckoutComplete;

  const CheckoutScreen({super.key, required this.cartItems, required this.onCheckoutComplete});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ProductRepository _repo = ProductRepository();
  String _paymentType = 'Net Payment'; // Options: Net Payment, Installment
  bool _isProcessing = false;

  double get _total => widget.cartItems.fold(0, (sum, item) => sum + item.sellingPrice);

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);

    try {
      final orderId = const Uuid().v4().substring(0, 8).toUpperCase();
      
      // 1. Create Order Model
      final orderItems = widget.cartItems.map((p) => OrderItem(
        productId: p.id,
        name: p.name,
        price: p.sellingPrice,
        quantity: 1, // Assuming 1 per entry for simplicity in this view
      )).toList();

      // Group items by ID for cleaner data
      final Map<String, OrderItem> consolidated = {};
      for (var item in orderItems) {
        if (consolidated.containsKey(item.productId)) {
          consolidated[item.productId]!.quantity += 1;
        } else {
          consolidated[item.productId] = item;
        }
      }

      final finalOrder = OrderModel(
        id: orderId,
        date: DateTime.now(),
        totalAmount: _total,
        paymentType: _paymentType,
        items: consolidated.values.toList(),
      );

      // 2. Update Stock & Save Order
      for (var item in consolidated.values) {
        await _repo.updateStock(item.productId, -item.quantity);
      }
      await _repo.saveOrder(finalOrder);

      // 3. Generate Receipt
      await _generateReceipt(finalOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Completed!")));
        widget.onCheckoutComplete();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _generateReceipt(OrderModel order) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(order.date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("POS SYSTEM", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18))),
              pw.Divider(),
              pw.Text("Order ID: ${order.id}"),
              pw.Text("Date: $dateStr"),
              pw.Text("Payment: ${order.paymentType}"),
              pw.Divider(),
              ...order.items.map((item) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text("${item.name} x${item.quantity}")),
                  pw.Text("${(item.price * item.quantity).toStringAsFixed(2)}"),
                ],
              )),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("${order.totalAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.BarcodeWidget(
                  data: order.id,
                  barcode: pw.Barcode.qrCode(),
                  width: 80,
                  height: 80,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Return Policy:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text("Items can be returned within 7 days of purchase with this receipt. Items must be in original condition.", style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("Thank you!", style: const pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  trailing: Text("Rs. ${item.sellingPrice}"),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Rs. $_total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Net Payment"),
                        value: "Net Payment",
                        groupValue: _paymentType,
                        onChanged: (val) => setState(() => _paymentType = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Installment"),
                        value: "Installment",
                        groupValue: _paymentType,
                        onChanged: (val) => setState(() => _paymentType = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: widget.cartItems.isEmpty ? null : _processCheckout,
                        icon: const Icon(Icons.print),
                        label: const Text("CONFIRM & PRINT RECEIPT"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}