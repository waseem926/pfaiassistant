import 'package:flutter/material.dart';

import 'app_theme_colors.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E3C72);
  static const Color accentPurple = Color(0xFF7C3AED);

  static const Color _darkSurface = Color(0xFF0F172A);
  static const Color _darkContainer = Color(0xFF1E293B);
  static const Color _darkInput = Color(0xFF334155);
  static const Color _lightInput = Color(0xFFF1F5F9);
  static const Color _lightInputField = Color(0xFFF8F9FA);
  static const Color _lightChipBg = Color(0xFFF3E8FF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: Colors.black87,
      primary: primaryBlue,
      primaryContainer: _lightInput,
      secondaryContainer: _lightChipBg,
      outline: Color(0xFFE2E8F0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightInputField,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkSurface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: _darkSurface,
      onSurface: Colors.white,
      primary: Color(0xFF60A5FA),
      primaryContainer: _darkContainer,
      secondaryContainer: Color(0xFF4C1D95),
      outline: Color(0xFF475569),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: _darkContainer,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkContainer,
      selectedItemColor: Color(0xFF60A5FA),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF334155)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static Color inputFillColor(BuildContext context) =>
      AppThemeColors.inputFillColor(context);

  static Color chipBackground(BuildContext context, {required bool selected}) =>
      AppThemeColors.chipBackground(context, selected: selected);

  static Color chipBorderColor(
    BuildContext context, {
    required bool selected,
  }) => AppThemeColors.chipBorderColor(context, selected: selected);

  static Color chipLabelColor(BuildContext context, {required bool selected}) =>
      AppThemeColors.chipLabelColor(context, selected: selected);

  static Color themeToggleBackground(BuildContext context) =>
      AppThemeColors.themeToggleBackground(context);
}
