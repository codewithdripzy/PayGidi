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
      ),
      primaryColor: PgColors.primary,
      scaffoldBackgroundColor: PgColors.scaffoldBackground,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PgColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
      fontFamily: PgFonts.fontFamily,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PgColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Dark theme definition - temp
  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PgColors.primary,
        brightness: Brightness.dark,
        secondary: PgColors.black,
      ),
      scaffoldBackgroundColor: PgColors.black,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PgColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PgColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PgColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
