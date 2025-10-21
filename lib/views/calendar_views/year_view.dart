import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatefulWidget {
  final DateTime focusedDay;

  const YearView({super.key, required this.focusedDay});

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat.MMMM().format(month),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textColor),
            ),
          ),
          _buildMonthGrid(month, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month, bool isDarkMode) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1).weekday;
    final List<Widget> dayWidgets = [];
    final baseColor = Theme.of(context).textTheme.bodySmall?.color ?? (isDarkMode ? Colors.white : Colors.black);
    final subtleTextColor = baseColor.withOpacity(0.6);

    // Add weekday headers
    for (var day in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: TextStyle(fontWeight: FontWeight.normal, color: subtleTextColor),
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
      final isToday = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;
      final isHovered = _hoveredDay != null && _hoveredDay == day;

      dayWidgets.add(
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredDay = day),
          onExit: (_) => setState(() => _hoveredDay = null),
          child: GestureDetector(
            onTap: () {
              // TODO: Handle day tap
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isToday ? Colors.red.withAlpha(128) : (isHovered ? Theme.of(context).hoverColor : Colors.transparent),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.normal,
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
}
