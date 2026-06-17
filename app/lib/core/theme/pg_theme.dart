// lib/core/theme/app_theme.dart

import 'package:app/core/theme/pg_colors.dart';
import 'package:app/core/theme/pg_fonts.dart';
import 'package:flutter/material.dart';

class PayGidiTheme {
  // Light theme definition
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PgColors.primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      primaryColor: PgColors.primary,
      scaffoldBackgroundColor: PgColors.scaffoldBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: PgColors.primary,
        unselectedItemColor: Colors.grey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: PgColors.black),
        titleTextStyle: TextStyle(
          color: PgColors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: PgColors.black),
        bodyMedium: TextStyle(fontSize: 14, color: PgColors.black),
        titleLarge: TextStyle(
            fontSize: 18, color: PgColors.black, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
      fontFamily: PgFonts.fontFamily,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PgColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    );
  }

  // Dark theme definition
  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PgColors.primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A1A),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A2A),
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: PgColors.primary,
        unselectedItemColor: Colors.white38,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
        titleLarge: TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
      fontFamily: PgFonts.fontFamily,
    );
  }
}
