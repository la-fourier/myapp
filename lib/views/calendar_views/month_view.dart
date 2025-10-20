import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthView extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const MonthView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime? _hoveredDay;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      onDaySelected: widget.onDaySelected,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, focusedDay) {
          final isSelected = isSameDay(widget.selectedDay, day);
          final isToday = isSameDay(day, DateTime.now());
          final isHovered = isSameDay(_hoveredDay, day);

          // Determine the decoration based on priority: Selected > Today > Hovered
          BoxDecoration? decoration;
          if (isSelected) {
            decoration = BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
            );
          } else if (isToday) {
            decoration = BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(128),
              borderRadius: BorderRadius.circular(8.0),
            );
          } else if (isHovered) {
            decoration = BoxDecoration(
              color: Theme.of(context).hoverColor,
              borderRadius: BorderRadius.circular(8.0),
            );
          } else {
            decoration = const BoxDecoration(); // No decoration
          }

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredDay = day),
            onExit: (_) => setState(() => _hoveredDay = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(4.0),
              decoration: decoration,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      // To avoid conflicts, use minimal calendarStyle and let the builder handle everything.
      calendarStyle: const CalendarStyle(
        defaultDecoration: BoxDecoration(),
        weekendDecoration: BoxDecoration(),
        outsideDecoration: BoxDecoration(),
        selectedDecoration: BoxDecoration(), 
        todayDecoration: BoxDecoration(), 
      ),
    );
  }
}
