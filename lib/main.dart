import 'dart:ui';
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

// Icon/ UX allg

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
    _showAsModalSheet((scrollController) => DayView(
          selectedDay: day,
          onBack: () => Navigator.of(context).pop(),
          scrollController: scrollController,
        ));
  }

  void _showAsModalSheet(Widget Function(ScrollController) builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: builder(scrollController),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  late final List<Widget> _mainViews;

  @override
  void initState() {
    super.initState();
    _mainViews = <Widget>[
      DashboardView(showAsModalSheet: _showAsModalSheet),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Logout',
        ),
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
            onPressed: () => _showAsModalSheet((controller) => SettingsView(scrollController: controller)),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showAsModalSheet((controller) => AccountView(scrollController: controller)),
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