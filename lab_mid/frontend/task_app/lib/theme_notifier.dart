import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/app_themes.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme;
  AppTheme _currentThemeKey;

  ThemeNotifier()
      : _currentTheme = appThemeData[AppTheme.deepPurple]!,
        _currentThemeKey = AppTheme.deepPurple {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  AppTheme get currentThemeKey => _currentThemeKey;

  void setTheme(AppTheme themeKey) async {
    if (appThemeData.containsKey(themeKey)) {
      _currentTheme = appThemeData[themeKey]!;
      _currentThemeKey = themeKey;
      notifyListeners();
      _saveTheme(themeKey);
    }
  }

  void _saveTheme(AppTheme themeKey) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeKey.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString =
        prefs.getString('theme') ?? AppTheme.deepPurple.toString();
    final themeKey = AppTheme.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => AppTheme.deepPurple);
    setTheme(themeKey);
  }
}
