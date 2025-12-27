import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Default to system settings initially for a seamless user experience
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Returns true if the current mode is Dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggles the theme between Light and Dark and persists the choice
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isDark);
    notifyListeners();
  }

  /// Persists the user's choice to local storage
  void _saveTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDark', isDark);
    } catch (e) {
      debugPrint("Theme Storage Error: $e");
    }
  }

  /// Loads the saved theme on app startup
  void _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('isDark')) {
        final isDark = prefs.getBool('isDark') ?? false;
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Theme Loading Error: $e");
    }
  }
}