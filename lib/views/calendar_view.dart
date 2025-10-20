import 'package:flutter/material.dart';
import 'package:myapp/views/calendar_views/month_view.dart';
import 'package:myapp/views/calendar_views/week_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  bool _isWeekView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
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
                label: const Text('Month'),
                selected: !_isWeekView,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _isWeekView = false;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Week'),
                selected: _isWeekView,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _isWeekView = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isWeekView
              ? WeekView(focusedDay: _focusedDay)
              : MonthView(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                ),
        ),
      ],
    );
  }
}
