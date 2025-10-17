import 'package:flutter/material.dart';
import 'package:myapp/views/month_view.dart';
import 'package:myapp/views/week_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarApp(),
    );
  }
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isWeekView = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Calendar'),
        actions: [
          Row(
            children: [
              const Text("Month"),
              Switch(
                value: _isWeekView,
                onChanged: (value) {
                  setState(() {
                    _isWeekView = value;
                  });
                },
              ),
              const Text("Week"),
            ],
          ),
        ],
      ),
      body: _isWeekView
          ? WeekView(focusedDay: _focusedDay)
          : SingleChildScrollView(
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
                      child: Text('Selected Day: ${_selectedDay!.toLocal()}'.split(' ')[0]),
                    ),
                ],
              ),
            ),
    );
  }
}
