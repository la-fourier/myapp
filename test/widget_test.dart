import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myapp/main.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/services/map_service.dart';
import 'package:myapp/services/settings_service.dart';
import 'package:myapp/services/plugin_service.dart';
import 'package:myapp/services/action_registry.dart';
import 'package:myapp/services/travel_time_service.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppState()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => MapService()),
          ChangeNotifierProvider(create: (context) => SettingsService()),
          ChangeNotifierProvider(create: (context) => PluginService(SettingsService())),
          ChangeNotifierProvider(create: (context) => ActionRegistry()),
          Provider(create: (context) => TravelTimeService()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
