// lib/themes/theme_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDarkTheme;
  ThemeData _themeData;

  ThemeManager(this._isDarkTheme)
    : _themeData = _isDarkTheme ? darkTheme : lightTheme;

  ThemeData get themeData => _themeData;
  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    _themeData = _isDarkTheme ? darkTheme : lightTheme;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }

  static Future<ThemeManager> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    return ThemeManager(isDarkTheme);
  }
}

// Global instance of ThemeManager
late ThemeManager themeManager;

// Global function to toggle the theme
Future<void> toggleTheme() async {
  themeManager.toggleTheme();
}
