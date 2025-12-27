import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Initialize Database Factory for Web/Chrome vs Mobile
  if (kIsWeb) {
    // Configures SQLite for Chrome
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Standard initialization for Android/iOS APK
    if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Supabase Initialization
  await Supabase.initialize(
    url: "https://gbtixmrjtcpzlxggjbeo.supabase.co",
    anonKey: "sb_publishable_9K-g11_qDKEgd2hdvszXEg_bZNp3Zeq",
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SmartPOSApp(),
    ),
  );
}

class SmartPOSApp extends StatelessWidget {
  const SmartPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Smart POS Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}