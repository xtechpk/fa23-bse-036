import 'package:flutter/material.dart';

enum AppTheme {
  deepPurple,
  oceanBlue,
  sunsetOrange,
}

final appThemeData = {
  // Line 39 (start of deepPurple) is correct as it's not a const map entry key
  AppTheme.deepPurple: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    // 💡 Fix 1: This block should be const if possible, but internal non-const color makes it complex.
    // The previous error was likely here or the floating action button.
    inputDecorationTheme: InputDecorationTheme(
      // Non-const usage of Colors.grey[600] requires the outer object to be mutable
      prefixIconColor: Colors.grey[600],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
      ),
      focusColor: Colors.deepPurple,
      floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
    ),
    // 💡 Fix 2: Add 'const' to FloatingActionButtonThemeData
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  ),
  AppTheme.oceanBlue: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: Colors.grey[600],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.teal, width: 2.0),
      ),
      focusColor: Colors.teal,
      floatingLabelStyle: const TextStyle(color: Colors.teal),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      ThemeGradients(
        scaffold: LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  ),
  AppTheme.sunsetOrange: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    useMaterial3: true,
    // 💡 Fix 4: Ensure the extensions list is constant.
    extensions: const <ThemeExtension<dynamic>>[
      ThemeGradients(
        // Const applies recursively, no need for const here
        scaffold: LinearGradient(
          colors: [Color(0xFFff9966), Color(0xFFff5e62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  ),
};

// Custom Theme Extension for Gradients
@immutable
class ThemeGradients extends ThemeExtension<ThemeGradients> {
  const ThemeGradients({required this.scaffold});

  final Gradient? scaffold;

  @override
  ThemeGradients copyWith({Gradient? scaffold}) {
    return ThemeGradients(scaffold: scaffold ?? this.scaffold);
  }

  @override
  ThemeGradients lerp(ThemeExtension<ThemeGradients>? other, double t) {
    if (other is! ThemeGradients) {
      return this;
    }
    return ThemeGradients(scaffold: Gradient.lerp(scaffold, other.scaffold, t));
  }
}
