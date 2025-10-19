import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthView extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const MonthView({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.focusedDay.year,
      widget.focusedDay.month,
      1,
    );
  }

  @override
  void didUpdateWidget(covariant MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDay.month != _currentMonth.month ||
        widget.focusedDay.year != _currentMonth.year) {
      setState(() {
        _currentMonth = DateTime(
          widget.focusedDay.year,
          widget.focusedDay.month,
          1,
        );
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildHeader(), _buildWeekDays(), _buildCalendarGrid()],
    );
  }

  Widget _buildHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final arrowColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: arrowColor),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat.yMMMM().format(_currentMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: arrowColor),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final days = DateFormat.E().dateSymbols.STANDALONESHORTWEEKDAYS;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayIndex = (index + 1) % 7;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            days[dayIndex],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final dayOffset = firstDayOfMonth.weekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: daysInMonth + dayOffset,
      itemBuilder: (context, index) {
        if (index < dayOffset) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - dayOffset + 1;
        final date = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          dayNumber,
        );

        return _DayCell(
          date: date,
          onDaySelected: widget.onDaySelected,
          isSelected: widget.selectedDay != null &&
              date.year == widget.selectedDay!.year &&
              date.month == widget.selectedDay!.month &&
              date.day == widget.selectedDay!.day,
          isToday: date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day,
        );
      },
    );
  }
}

class _DayCell extends StatefulWidget {
  final DateTime date;
  final Function(DateTime, DateTime) onDaySelected;
  final bool isSelected;
  final bool isToday;

  const _DayCell({
    required this.date,
    required this.onDaySelected,
    required this.isSelected,
    required this.isToday,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => widget.onDaySelected(widget.date, widget.date),
        child: Container(
          margin: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.blue.shade300
                : _isHovering
                ? Theme.of(context).hoverColor
                : widget.isToday
                ? Colors.blue.shade100
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Text(
              '${widget.date.day}',
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.white
                    : widget.isToday
                    ? Colors.blue.shade900
                    : isDarkMode
                    ? Colors.white
                    : Colors.black87,
                fontWeight: widget.isSelected || widget.isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
