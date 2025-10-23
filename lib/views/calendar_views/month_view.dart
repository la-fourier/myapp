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

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Constrain the calendar width so it doesn't stretch on very wide displays.
    // Use LayoutBuilder to compute per-day cell size and scale text accordingly.
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: LayoutBuilder(builder: (context, constraints) {
            // Total horizontal padding inside the TableCalendar is not easily known,
            // but we can estimate cell width by dividing available width by 7 (days per week).
            final double availableWidth = constraints.maxWidth;
            final double cellWidth = (availableWidth) / 7.0;
            // Base font size proportional to cell size, clamp to a reasonable range.
            final double dayFontSize = cellWidth * 0.35
                .clamp(10.0, 20.0);

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
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(128),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    );
                  } else if (isToday) {
                    decoration = BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withAlpha(128),
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

                  final scale = isSelected || isHovered ? 1.1 : 1.0;

                  // Use FittedBox to ensure the number scales to available cell size without stretching cells.
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredDay = day),
                    onExit: (_) => setState(() => _hoveredDay = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.all(4.0),
                      transform: Matrix4.diagonal3Values(scale, scale, 1.0),
                      transformAlignment: Alignment.center,
                      decoration: decoration,
                      child: Center(
                        child: SizedBox(
                          width: cellWidth,
                          height: cellWidth,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: dayFontSize,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
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
          }),
        ),
      ),
    );
  }
}
