import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFFFF7FB);
  static const Color primary = Color(0xFFC2185B);
  static const Color accent = Color(0xFF8E24AA);
  static const Color muted = Color(0xFF9E9E9E);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFF44336);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accent),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
          color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
    // Enhanced card theme
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
  );
}
