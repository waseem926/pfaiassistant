import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryBlue = Color(0xFF1E3C72);
  static const Color _darkSurface = Color(0xFF0F172A);
  static const Color _darkContainer = Color(0xFF1E293B);
  static const Color _lightInputGrey = Color(0xFFF1F5F9);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: Colors.black87,
      primaryContainer: _lightInputGrey,
      secondaryContainer: const Color(0xFFF3E8FF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkSurface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.dark,
      surface: _darkSurface,
      onSurface: Colors.white,
      primaryContainer: _darkContainer,
      secondaryContainer: const Color(0xFF334155),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _darkContainer,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
