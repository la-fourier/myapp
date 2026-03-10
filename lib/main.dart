// Google Firebase STudio: https://studio.firebase.google.com/crealcraft-96586257


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/services/map_service.dart';
import 'package:myapp/services/settings_service.dart';
import 'package:myapp/services/plugin_service.dart';
import 'package:myapp/services/action_registry.dart';
import 'package:myapp/services/travel_time_service.dart';
import 'package:myapp/views/auth/login_view.dart';
import 'package:myapp/views/auth/signup_view.dart';
import 'package:myapp/views/main/main_screen.dart';
import 'package:myapp/widgets/loading_overlay.dart';
import 'package:myapp/views/shared_calendar_view.dart';

// All main Todos from this file have been addressed.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final settingsService = SettingsService();
  await settingsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => MapService()),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider(create: (context) => PluginService(settingsService)),
        ChangeNotifierProvider(create: (context) => ActionRegistry()),
        Provider(create: (context) => TravelTimeService()),
      ],
      child: MyApp(key: UniqueKey()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AppState>(
      builder: (context, themeProvider, appState, child) {
        return MaterialApp(
          title: 'Synapse',
          theme: themeProvider.getTheme(),
          darkTheme: themeProvider.getTheme(),
          themeMode: themeProvider.themeMode,
          locale: appState.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('es'),
          ],
          builder: (context, child) {
            return LoadingOverlay(child: child!);
          },
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (settings.name!.startsWith('/shared/')) {
              final encodedData = settings.name!.substring('/shared/'.length);
              return MaterialPageRoute(
                builder: (context) => SharedCalendarView(encodedData: encodedData),
              );
            }
            if (settings.name!.startsWith('/planner/')) {
              final uri = Uri.parse(settings.name!);
              final parts = uri.pathSegments;
              if (parts.length >= 2) {
                final uid = parts[1];
                final credibility = uri.queryParameters['credibility'] ?? 'unknown';
                return MaterialPageRoute(
                  builder: (context) => SharedCalendarView(contactUid: uid, credibility: credibility),
                );
              }
            }
            return null;
          },
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginView(),
            '/signup': (context) => SignupView(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.loggedInUser == null) {
          return const LoginView();
        } else {
          return const MainScreen();
        }
      },
    );
  }
}
