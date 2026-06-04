import 'package:flutter/material.dart';

/// Theme-aware color helpers for widgets.
abstract final class AppThemeColors {
  AppThemeColors._();

  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color _darkInput = Color(0xFF334155);
  static const Color _lightInputField = Color(0xFFF8F9FA);
  static const Color _lightChipBg = Color(0xFFF3E8FF);
  static const Color _lightChipBorder = Color(0xFFD8B4FE);

  static Color inputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkInput
        : _lightInputField;
  }

  static Color chipBackground(BuildContext context, {required bool selected}) {
    if (!selected) return Colors.transparent;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF4C1D95)
        : _lightChipBg;
  }

  static Color chipBorderColor(BuildContext context, {required bool selected}) {
    if (!selected) return Colors.transparent;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF7C3AED)
        : _lightChipBorder;
  }

  static Color chipLabelColor(BuildContext context, {required bool selected}) {
    if (!selected) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFC4B5FD)
        : accentPurple;
  }

  static Color themeToggleBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFE0F2FE);
  }
}
