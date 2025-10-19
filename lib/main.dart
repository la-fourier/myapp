import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/notification_service.dart';
import 'package:myapp/views/lock_screen_view.dart';
import 'package:myapp/views/month_view.dart';
import 'package:myapp/views/week_view.dart';
import 'package:myapp/views/year_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('de', ''), // German, no country code
      ],
      home: const CalendarApp(),
    );
  }
}

enum CalendarView { month, week, year }

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarView _currentView = CalendarView.month;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Widget _buildView() {
    switch (_currentView) {
      case CalendarView.month:
        return SingleChildScrollView(
          child: Column(
            children: [
              MonthView(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
              ),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selected Day: ${_selectedDay!.toLocal()}'
                        .split(' ')[0],
                  ),
                ),
            ],
          ),
        );
      case CalendarView.week:
        return WeekView(focusedDay: _focusedDay);
      case CalendarView.year:
        return const YearView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LockScreenView()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Test Notification'),
              onTap: () {
                _notificationService.showNotification(
                  1,
                  'Test Notification',
                  'This is a test',
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                _currentView == CalendarView.month,
                _currentView == CalendarView.week,
                _currentView == CalendarView.year,
              ],
              onPressed: (index) {
                setState(() {
                  _currentView = CalendarView.values[index];
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Month'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Week'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Year'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildView()),
        ],
      ),
    );
  }
}