import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _showQueryField = false;

  bool get isDarkMode => _isDarkMode;
  bool get showQueryField => _showQueryField;

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

  void toggleShowQueryField() {
    _showQueryField = !_showQueryField;
    notifyListeners();
  }
}
