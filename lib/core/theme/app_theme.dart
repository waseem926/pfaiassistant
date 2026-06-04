import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors 
  static const Color _primaryBlue = Color(0xFF1E3C72);
  static const Color _accentLavender = Color(0xFF7C3AED);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
      surface: Theme.of(context).colorScheme.surface,
      onSurface: Theme.of(context).colorScheme.onSurface87,
      primaryContainer: const Color(0xFFF1F5F9),
      secondaryContainer: const Color(0xFFF3E8FF),
      ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
    ),  
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
     seedColor: _primaryBlue,
     brightness: Brightness.dark,
     surface: const Color(0xFF0F172A),
     onSurface: Theme.of(context).colorScheme.surface,
     primaryContainer: const Color(0xFF1E293B),
     secondaryContainer: const Color(0xFF334155),
     ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
    ) 
  );
}