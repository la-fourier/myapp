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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat.yMMMM().format(_currentMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
        // To start week with Monday
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
    // Adjust for Monday start: weekday returns 1 for Monday, 7 for Sunday.
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
          return const SizedBox.shrink(); // Empty cell before the month starts
        }

        final dayNumber = index - dayOffset + 1;
        final date = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          dayNumber,
        );
        final isToday =
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        final isSelected =
            widget.selectedDay != null &&
            date.year == widget.selectedDay!.year &&
            date.month == widget.selectedDay!.month &&
            date.day == widget.selectedDay!.day;

        return GestureDetector(
          onTap: () => widget.onDaySelected(date, date),
          child: Container(
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade300
                  : isToday
                  ? Colors.blue.shade100
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? Colors.blue.shade900
                      : Colors.black87,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
