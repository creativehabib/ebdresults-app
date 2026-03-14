import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themeKey = "theme_mode";

  ThemeMode get themeMode => _themeMode;

  // থিম পরিবর্তন এবং সেভ করা
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // 0 = System, 1 = Light, 2 = Dark
    prefs.setInt(_themeKey, mode.index);
  }

  // অ্যাপ চালু হওয়ার সময় সেভ করা থিম লোড করা
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }
}