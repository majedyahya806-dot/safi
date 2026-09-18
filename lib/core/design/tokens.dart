import 'package:flutter/material.dart';

class SafiColors {
  static const background = Color(0xFF0B0F1A);
  static const surface = Color(0xFF151B2B);
  static const surfaceElevated = Color(0xFF1D2438);
  static const primary = Color(0xFF21E0B0);
  static const secondary = Color(0xFF6E7BFF);
  static const critical = Color(0xFFFF5A6A);
  static const high = Color(0xFFFFA23A);
  static const medium = Color(0xFFFFD65A);
  static const unknown = Color(0xFF8A93A8);
  static const textPrimary = Color(0xFFF3F6FA);
  static const textSecondary = Color(0xFFA8B2C7);
  static const textMuted = Color(0xFF6E7891);
  static const border = Color(0xFF232B42);
}

class SafiTypography {
  static const display = TextStyle(fontSize: 44, fontWeight: FontWeight.w700, fontFamily: 'Cairo', height: 1.1);
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Cairo');
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, fontFamily: 'Cairo', height: 1.7);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Inter');
}

class SafiRadius {
  static const card = 16.0;
  static const button = 12.0;
}

class SafiTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SafiColors.background,
      colorScheme: const ColorScheme.dark(
        primary: SafiColors.primary,
        secondary: SafiColors.secondary,
        surface: SafiColors.surface,
        error: SafiColors.critical,
        onSurface: SafiColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SafiColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: SafiColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: SafiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafiRadius.card), side: const BorderSide(color: SafiColors.border)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SafiColors.primary,
          foregroundColor: SafiColors.background,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafiRadius.button)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
