import 'package:flutter/material.dart';
import 'package:myapp/views/calendar_views/month_view.dart';
import 'package:myapp/views/calendar_views/week_view.dart';
import 'package:myapp/views/calendar_views/year_view.dart';

class CalendarView extends StatefulWidget {
  final Function(DateTime) onDaySelected; // Expect the callback

  const CalendarView({super.key, required this.onDaySelected});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  int _viewIndex = 0; // 0 for Month, 1 for Week, 2 for Year
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // This internal handler now calls the main callback
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      widget.onDaySelected(selectedDay); // Trigger the navigation
    }
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChoiceChip(
                label: const Text('Week'),
                selected: _viewIndex == 1,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewIndex = 1;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Month'),
                selected: _viewIndex == 0,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewIndex = 0;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Year'),
                selected: _viewIndex == 2,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewIndex = 2;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _viewIndex,
            children: [
              MonthView(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
              ),
              WeekView(focusedDay: _focusedDay),
              YearView(
                focusedDay: _focusedDay,
                onDaySelected: widget.onDaySelected, // Pass callback to YearView
              ),
            ],
          ),
        ),
      ],
    );
  }
}
