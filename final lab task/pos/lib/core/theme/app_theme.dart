import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final Color _primary = Colors.blueAccent;

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: _primary),
    scaffoldBackgroundColor: const Color(0xFFF4F6F8),
    cardColor: Colors.white,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 6, backgroundColor: _primary)),
    cardTheme: CardTheme(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: _primary, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF0B0E14),
    cardColor: const Color(0xFF0F1720),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
}

// [5:05 PM, 12/27/2025] M Awais: sonumadni3@gmail.com
// [5:07 PM, 12/27/2025] M Awais: @#mrawais332