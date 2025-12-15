import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Support")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("How can we help?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: subCtrl, decoration: const InputDecoration(labelText: "Subject", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, maxLines: 5, decoration: const InputDecoration(labelText: "Message", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().submitSupportTicket(subCtrl.text, msgCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket Submitted!")));
                Navigator.pop(context);
              },
              child: const Text("Submit Ticket"),
            )
          ],
        ),
      ),
    );
  }
}