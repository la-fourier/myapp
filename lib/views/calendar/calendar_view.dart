import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:myapp/views/calendar/month_view.dart';
import 'package:myapp/views/calendar/week_view.dart';
import 'package:myapp/views/calendar/year_view.dart';

class CalendarView extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const CalendarView({super.key, required this.onDaySelected});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  int _viewIndex = 0; // 0 for Month, 1 for Week, 2 for Year
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      widget.onDaySelected(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.loggedInUser;
        if (user == null) {
          return const Center(child: Text('No user logged in.'));
        }

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
                    onDaySelected: widget.onDaySelected,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}