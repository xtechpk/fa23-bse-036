// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme for bright shop environments
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.brown, // Bakery-themed primary color
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
  );

  // Dark Theme for low-light or evening sales
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.brown,
      brightness: Brightness.dark,
    ),
  );
}