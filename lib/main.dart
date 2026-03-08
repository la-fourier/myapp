// Google Firebase STudio: https://studio.firebase.google.com/crealcraft-96586257


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/auth/login_view.dart';
import 'package:myapp/views/main/main_screen.dart';
import 'package:myapp/widgets/loading_overlay.dart';
import 'package:myapp/views/auth/signup_view.dart';

// All main Todos from this file have been addressed.

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
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
          title: 'Orgaa stuff',
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
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginView(),
            '/signup': (context) => const SignupView(),
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
