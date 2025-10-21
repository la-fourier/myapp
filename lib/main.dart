import 'package:flutter/material.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:myapp/views/account_view.dart';
import 'package:myapp/views/calendar_view.dart';
import 'package:myapp/views/dashboard_view.dart';
import 'package:myapp/views/people_view.dart';
import 'package:myapp/views/settings_view.dart';
import 'package:myapp/views/stats_view.dart';
import 'package:myapp/views/today_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: themeProvider.getTheme(),
            home: const MainScreen(),
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardView(),
    const CalendarView(),
    const TodayView(),
    const PeopleView(),
    const StatsView(),
    const AccountView(),
    const SettingsView(),
  ];

  static const List<String> _widgetTitles = <String>[
    'Dashboard',
    'Calendar',
    'Today',
    'People',
    'Stats',
    'Account',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex]),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
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
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      'crealcraft',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () => _onItemTapped(0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Calendar'),
                    onTap: () => _onItemTapped(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Today'),
                    onTap: () => _onItemTapped(2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('People'),
                    onTap: () => _onItemTapped(3),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Stats'),
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _onItemTapped(6),
                    tooltip: 'Settings',
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () => _onItemTapped(5),
                    tooltip: 'Account',
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () {
                      // TODO: Implement sync functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing data...')),
                      );
                    },
                    tooltip: 'Sync',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
