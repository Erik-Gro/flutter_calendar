import 'package:flutter/material.dart';
import 'package:flutter_calendar/shared/consts/enums/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  bool _autoClosePreference = true;

  AppTheme get currentTheme => _currentTheme;
  bool get autoClosePreference => _autoClosePreference;

  Future<void> loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedTheme = prefs.getString('app_theme');
    if (savedTheme != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => AppTheme.light,
      );
    }

    _autoClosePreference = prefs.getBool('auto_close_picker') ?? true;

    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.toString());
  }

  Future<void> setAutoClose(bool value) async {
    _autoClosePreference = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_close_picker', value);
  }
}