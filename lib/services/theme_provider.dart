import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme { purple, green, warm }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.purple;
  ThemeMode _themeMode = ThemeMode.light;
  bool _showQueryField = false;
 
  AppTheme get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  bool get showQueryField => _showQueryField;
 
  double get _radiusValue => 16.0;

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

  ThemeData _buildDefaultTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
    final radius = _radiusValue;
    return baseTheme.copyWith(
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }

  ThemeData _buildPurpleTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
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
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
    );
  }

  ThemeData _buildGreenTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
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
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      listTileTheme: baseTheme.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      tabBarTheme: baseTheme.tabBarTheme.copyWith(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(_radiusValue),
          color: baseTheme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      floatingActionButtonTheme: baseTheme.floatingActionButtonTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
    );
  }

  ThemeData _buildWarmTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
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
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      dialogTheme: baseTheme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusValue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeMode == ThemeMode.light
              ? const Color(0xFFD2B48C)
              : baseTheme.elevatedButtonTheme.style?.backgroundColor!.resolve(
                  <WidgetState>{},
                ), // Tan// Tan
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
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
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleShowQueryField() {
    _showQueryField = !_showQueryField;
    notifyListeners();
  }
}
