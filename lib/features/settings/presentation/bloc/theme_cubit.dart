import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  static const _storageKey = 'theme_mode';

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(nextMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      nextMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
