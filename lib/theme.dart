import 'package:flutter/material.dart';

class AppColors {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const adminGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const incomeGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const expenseGradient = LinearGradient(
    colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardBackground = Colors.white;
  static const textColor = Color(0xFF333333);
  static const secondaryTextColor = Color(0xFF666666);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF667EEA),
        primary: const Color(0xFF667EEA),
      ),
      fontFamily: 'Segoe UI', // Note: Needs to be added to pubspec or mapped to default
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
