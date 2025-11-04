import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/login_screen.dart';
import 'package:task_app/theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Task App',
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}
