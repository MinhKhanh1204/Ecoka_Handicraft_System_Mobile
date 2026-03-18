import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/shared_prefs.dart';

part 'theme_provider.g.dart';

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeState build() {
    final mode = SharedPrefs.getThemeMode();
    return ThemeState(
      themeMode: mode == 'dark' ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    state = ThemeState(themeMode: newMode);
    await SharedPrefs.saveThemeMode(newMode == ThemeMode.dark ? 'dark' : 'light');
  }
}

