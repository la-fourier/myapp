import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime) onDaySelected;

  const YearView({super.key, required this.focusedDay, required this.onDaySelected});

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  DateTime? _hoveredDay;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 months per row
        childAspectRatio: 0.8, // Adjust for taller month view
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = DateTime(widget.focusedDay.year, index + 1);
        return _buildMonth(context, month);
      },
    );
  }

  Widget _buildMonth(BuildContext context, DateTime month) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat.MMMM().format(month),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildMonthGrid(month),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1).weekday;
    final List<Widget> dayWidgets = [];
    final Color subtleTextColor = (isDarkMode ? Colors.white : Colors.black).withAlpha(128);

    // Add weekday headers
    for (var day in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: TextStyle(fontWeight: FontWeight.normal, color: subtleTextColor, fontSize: 12),
          ),
        ),
      );
    }

    // Add empty cells for days before the 1st of the month
    for (int i = 1; i < firstDayOfMonth; i++) {
      dayWidgets.add(Container());
    }

    // Add day cells
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(month.year, month.month, i);
      final isToday = isSameDay(day, DateTime.now());
      final isHovered = isSameDay(day, _hoveredDay);

      dayWidgets.add(
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredDay = day),
          onExit: (_) => setState(() => _hoveredDay = null),
          child: GestureDetector(
            onTap: () => widget.onDaySelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: isHovered ? (Matrix4.identity()..scale(1.1, 1.1)) : Matrix4.identity(),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday
                    ? Theme.of(context).colorScheme.tertiary.withAlpha(128)
                    : (isHovered ? Theme.of(context).hoverColor : Colors.transparent),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
