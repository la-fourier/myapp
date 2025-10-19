import 'package:flutter/material.dart';
import 'package:myapp/views/calendar_views/month_view.dart';
import 'package:myapp/views/calendar_views/tasks_list_view.dart';
import 'package:myapp/views/calendar_views/year_view.dart';

enum CalendarViewType { tasks, month, year }

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarViewType _currentView = CalendarViewType.month;

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
      case CalendarViewType.tasks:
        return const TasksListView();
      case CalendarViewType.month:
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
      case CalendarViewType.year:
        return YearView(
          onDaySelected: (day) {
            setState(() {
              _focusedDay = day;
              _selectedDay = day;
              _currentView = CalendarViewType.month;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(12.0),
            isSelected: [
              _currentView == CalendarViewType.tasks,
              _currentView == CalendarViewType.month,
              _currentView == CalendarViewType.year,
            ],
            onPressed: (index) {
              setState(() {
                _currentView = CalendarViewType.values[index];
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Tasks list', style: TextStyle(color: onSurfaceColor)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Month', style: TextStyle(color: onSurfaceColor)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Year', style: TextStyle(color: onSurfaceColor)),
              ),
            ],
          ),
        ),
        Expanded(child: _buildView()),
      ],
    );
  }
}
