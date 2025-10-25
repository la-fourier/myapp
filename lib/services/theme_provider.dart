import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData getTheme() {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Fredericka the Great'),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Fredericka the Great'),
    );
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
