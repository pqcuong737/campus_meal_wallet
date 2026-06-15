import 'package:flutter/material.dart';

import 'campus_colors.dart';

class CampusTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CampusColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CampusColors.primary,
        primary: CampusColors.primary,
        error: CampusColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: CampusColors.text,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: CampusColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CampusColors.surfaceBlue,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CampusColors.border,
            width: 2.4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CampusColors.border,
            width: 2.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CampusColors.blue,
            width: 2.4,
          ),
        ),
      ),
    );
  }
}