import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme { purple, green, warm }

enum AppBorderRadius { rounded, squared }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.purple;
  ThemeMode _themeMode = ThemeMode.light;
  bool _showQueryField = false;
  AppBorderRadius _borderRadius = AppBorderRadius.rounded;

  AppTheme get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  bool get showQueryField => _showQueryField;
  AppBorderRadius get borderRadius => _borderRadius;

  ThemeData getTheme() {
    switch (_currentTheme) {
      case AppTheme.green:
        return _buildGreenTheme();
      case AppTheme.warm:
        return _buildWarmTheme();
      case AppTheme.purple:
        return _buildPurpleTheme();
    }
  }

  void setBorderRadius(AppBorderRadius borderRadius) {
    _borderRadius = borderRadius;
    notifyListeners();
  }

  ThemeData _buildDefaultTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
    final radius = _borderRadius == AppBorderRadius.rounded ? 12.0 : 2.0;
    return baseTheme.copyWith(
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }

  ThemeData _buildPurpleTheme() {
    final baseTheme = _buildDefaultTheme();
    final radius = _borderRadius == AppBorderRadius.rounded ? 12.0 : 2.0;
    return baseTheme.copyWith(
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.frederickaTheGreatTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.frederickaTheGreatTextTheme(
        baseTheme.primaryTextTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: _themeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  ThemeData _buildGreenTheme() {
    final baseTheme = _buildDefaultTheme();
    final radius = _borderRadius == AppBorderRadius.rounded ? 8.0 : 2.0;
    return baseTheme.copyWith(
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.latoTextTheme(baseTheme.primaryTextTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: _themeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark,
      ),
      cardTheme: baseTheme.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  ThemeData _buildWarmTheme() {
    final baseTheme = _buildDefaultTheme();
    final radius = _borderRadius == AppBorderRadius.rounded ? 10.0 : 2.0;
    return baseTheme.copyWith(
      splashFactory: InkSparkle.splashFactory,
      textTheme: GoogleFonts.merriweatherTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.merriweatherTextTheme(
        baseTheme.primaryTextTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD2B48C),
        brightness: _themeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark,
      ), // Tan
      scaffoldBackgroundColor: _themeMode == ThemeMode.light
          ? const Color(0xFFF5F5DC)
          : baseTheme.scaffoldBackgroundColor, // Beige
      cardTheme: baseTheme.cardTheme.copyWith(
        color: _themeMode == ThemeMode.light
            ? const Color(0xFFFAF0E6)
            : baseTheme.cardTheme.color, // Linen
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeMode == ThemeMode.light
              ? const Color(0xFFD2B48C)
              : baseTheme.elevatedButtonTheme.style?.backgroundColor!.resolve(
                  <MaterialState>{},
                ), // Tan
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void toggleShowQueryField() {
    _showQueryField = !_showQueryField;
    notifyListeners();
  }
}
