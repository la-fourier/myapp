import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksListView extends StatefulWidget {
  const TasksListView({super.key});

  @override
  State<TasksListView> createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  late DateTime _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = _getMonday(DateTime.now());
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final arrowColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: arrowColor),
                onPressed: _previousWeek,
              ),
              Text(
                '${DateFormat.MMMMd().format(_currentWeek)} - ${DateFormat.MMMMd().format(_currentWeek.add(const Duration(days: 6)))}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: arrowColor),
                onPressed: _nextWeek,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = _currentWeek.add(Duration(days: index));
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(DateFormat.d().format(day)),
                  ),
                  title: Text(DateFormat.EEEE().format(day)),
                  subtitle: const Text('No events'), // Placeholder
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
