import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/auth_check_screen.dart';
import 'package:task_app/theme_notifier.dart';
import 'package:task_app/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
          home: const AuthCheckScreen(),
        );
      },
    );
  }
}
