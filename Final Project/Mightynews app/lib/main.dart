import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/blog_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BlogProvider()),
      ],
      child: const MightyApp(),
    ),
  );
}

class MightyApp extends StatelessWidget {
  const MightyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mighty News Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
      ),
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => auth.user == null ? const LoginScreen() : const MainLayout(),
      ),
    );
  }
}