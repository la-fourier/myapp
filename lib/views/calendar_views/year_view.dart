import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatefulWidget {
  final void Function(DateTime) onDaySelected;
  final DateTime focusedDay;

  const YearView({super.key, required this.onDaySelected, required this.focusedDay});

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  late DateTime _currentYear;

  @override
  void initState() {
    super.initState();
    _currentYear = widget.focusedDay;
  }

    @override
  void didUpdateWidget(YearView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDay.year != oldWidget.focusedDay.year) {
      setState(() {
        _currentYear = widget.focusedDay;
      });
    }
  }


  void _previousYear() {
    setState(() {
      _currentYear = DateTime(_currentYear.year - 1);
    });
  }

  void _nextYear() {
    setState(() {
      _currentYear = DateTime(_currentYear.year + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final arrowColor = isDarkMode ? Colors.white : Colors.black;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: arrowColor),
                  onPressed: _previousYear,
                ),
                Text(
                  DateFormat.y().format(_currentYear),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: arrowColor),
                  onPressed: _nextYear,
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 0.8, // Adjusted aspect ratio for taller cards
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = DateTime(_currentYear.year, index + 1);
              return Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _MonthCalendar(
                  month: month,
                  onDaySelected: widget.onDaySelected,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final void Function(DateTime) onDaySelected;

  const _MonthCalendar({required this.month, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // Monday is 1, Sunday is 7

    final List<String> weekdayNames = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

    List<TableRow> buildCalendarRows() {
      final List<TableRow> rows = [];
      List<Widget> weekChildren = [];

      rows.add(TableRow(
        children: weekdayNames
            .map((name) => Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ))
            .toList(),
      ));

      for (int i = 1; i < firstWeekday; i++) {
        weekChildren.add(Container());
      }

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        weekChildren.add(
          _DayCell(date: date, onDaySelected: onDaySelected),
        );

        if (weekChildren.length == 7) {
          rows.add(TableRow(children: List.from(weekChildren)));
          weekChildren.clear();
        }
      }

      if (weekChildren.isNotEmpty) {
        while (weekChildren.length < 7) {
          weekChildren.add(Container());
        }
        rows.add(TableRow(children: weekChildren));
      }
      return rows;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            DateFormat.MMM().format(month),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Table(
              children: buildCalendarRows(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onDaySelected;

  const _DayCell({required this.date, required this.onDaySelected});

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: () => widget.onDaySelected(widget.date),
        borderRadius: BorderRadius.circular(4),
        child: AspectRatio(
          aspectRatio: 1, // Make the cell a square
          child: Container(
            decoration: BoxDecoration(
              color: _isHovering ? Theme.of(context).hoverColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Text(
                  '${widget.date.day}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
