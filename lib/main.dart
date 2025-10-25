import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/user/account_view.dart';
import 'package:myapp/views/calendar/calendar_view.dart';
import 'package:myapp/views/calendar/day_view.dart';
import 'package:myapp/views/main/dashboard_view.dart';
import 'package:myapp/views/auth/login_view.dart';
import 'package:myapp/views/settings/settings_view.dart';
import 'package:myapp/views/main/stats_view.dart';
import 'package:myapp/views/main/today_view.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/loading_overlay.dart';

import 'package:myapp/backend_integrations/google.dart';
import 'package:myapp/backend_integrations/github.dart';

void main() {
  runApp(MyApp());
}

// TODO

// Repariere Notifications :/ State/Thread stuff scheint nicht nur gutes/richtige zu tun

// Backend stuff in own thread

// Wochentage noch anders hervorheben

// Restliche Views implementieren
// Reclaim Funktionalität               - Cards/Tiles im Week View anders
// Account Settings, Settings allg
// Sync Functionality Google Cloud, Local Storage, Firebase/Firestore, GitHub schlecht   mit Login Stuff!
// Option Extraverschlüsselung

// Abstraktes Action Concept, mehr Code Abstraction

// Unterschiedliche Sprachen

// vll Keybindings
// schönere LadeAnimation/Animation allgemeinx

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Orgaa stuff',
            theme: themeProvider.getTheme(),
            builder: (context, child) {
              return LoadingOverlay(
                child: child!,
              );
            },
            home: const LoginView(),
            routes: {
              '/main': (context) => const MainScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String syncService = 'google'; // or 'github' or 'none'
  Map<String, dynamic> appData = {}; // Placeholder for app data to sync

  void _handleDaySelected(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // Start at 60% of the screen height
          maxChildSize: 0.9, // Can expand up to 90%
          minChildSize: 0.3, // Can shrink down to 30%
          builder: (BuildContext context, ScrollController scrollController) {
            return DayView(
              selectedDay: day,
              onBack: () => Navigator.of(context).pop(), // Close the sheet
              scrollController: scrollController, // Pass the scroll controller
            );
          },
        );
      },
    );
  }

  late final List<Widget> _mainViews;

  @override
  void initState() {
    super.initState();
    _mainViews = <Widget>[
      const DashboardView(),
      CalendarView(onDaySelected: _handleDaySelected),
      const TodayView(),
      const StatsView(),
    ];
  }

  static const List<String> _widgetTitles = <String>[
    'Dashboard',
    'Calendar',
    'Today',
    'Stats',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              final googleService = GoogleDriveService();
              final githubService = GitHubService();

              if (syncService == 'google') {
                googleService.connect();
                googleService.uploadJson('app_data.json', appData);
              } else if (syncService == 'github') {
                githubService.connect();
                githubService.uploadJson('app_data.json', appData);
              }
              Fluttertoast.showToast(
                  msg: "Syncing...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            },
            tooltip: 'Sync',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateTo(const SettingsView()),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _navigateTo(const AccountView()),
            tooltip: 'Account',
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _mainViews.elementAt(_selectedIndex);
        } else {
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today),
                    label: Text('Calendar'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.today_outlined),
                    selectedIcon: Icon(Icons.today),
                    label: Text('Today'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: Text('Stats'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _mainViews.elementAt(_selectedIndex)),
            ],
          );
        }
      }),
      bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return NavigationBar(
            onDestinationSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}