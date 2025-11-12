import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/auth/login_view.dart';
import 'package:myapp/views/main/main_screen.dart';
import 'package:myapp/widgets/loading_overlay.dart';
import 'package:myapp/views/auth/signup_view.dart';

// TODO Test signup
// TODO ausbessern Form Errors, dass man die Keys bearbeiten kann :/

// TODO ausbessern Settings besser Strukturieren
// TODO AccountView besser bearbeitbar machen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Orgaa stuff',
          theme: themeProvider.getTheme(),
          darkTheme: themeProvider.getTheme(),
          themeMode: themeProvider.themeMode,
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
