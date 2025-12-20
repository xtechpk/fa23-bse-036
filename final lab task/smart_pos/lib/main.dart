import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your provided URL and Key
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  runApp(const SmartPOSApp());
}

class SmartPOSApp extends StatelessWidget {
  const SmartPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart POS & Inventory',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(), // We will create this next
    );
  }
}