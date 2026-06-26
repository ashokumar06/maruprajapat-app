import 'package:flutter/material.dart';

class ThemeConfig {
  // Primary colors
  static const Color primary = Color(0xFFE67E22);
  static const Color primaryLight = Color(0xFFF4A261);
  static const Color secondary = Color(0xFFA65E2E);
  static const Color accent = Color(0xFFD4A373);
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFDF9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8DCCF);
  static const Color border = Color(0xFFD8C3A5);
  static const Color shadow = Color(0x14A65E2E); // rgba(166,94,46,0.08)

  // Text colors
  static const Color textPrimary = Color(0xFF4A2C1A);
  static const Color textSecondary = Color(0xFF7A6A58);
  static const Color textHint = Color(0xFFA89A8C);
  static const Color textDisabled = Color(0xFFBDB5AD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFB8C00);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      primaryColorLight: primaryLight,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      cardColor: card,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          side: const BorderSide(color: border),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
