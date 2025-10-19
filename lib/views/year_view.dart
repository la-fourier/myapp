import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatefulWidget {
  const YearView({super.key});

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  late DateTime _currentYear;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now();
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousYear,
              ),
              Text(
                DateFormat.y().format(_currentYear),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextYear,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8, // Adjusted for table layout
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = DateTime(_currentYear.year, index + 1);
              return _MonthCalendar(month: month);
            },
          ),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime month;

  const _MonthCalendar({required this.month});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // Monday is 1, Sunday is 7

    // Using German short names for weekdays
    final List<String> weekdayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    List<TableRow> buildCalendarRows() {
      final List<TableRow> rows = [];
      List<Widget> weekChildren = [];

      // Header Row
      rows.add(TableRow(
        children: weekdayNames.map((name) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        )).toList(),
      ));

      // Day Rows
      // Add empty cells for the beginning of the first week
      for (int i = 1; i < firstWeekday; i++) {
        weekChildren.add(Container());
      }

      // Add day cells
      for (int day = 1; day <= daysInMonth; day++) {
        weekChildren.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '$day',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        );

        if (weekChildren.length == 7) {
          rows.add(TableRow(children: List.from(weekChildren)));
          weekChildren.clear();
        }
      }

      // Add the last week if it's not full
      if (weekChildren.isNotEmpty) {
        while (weekChildren.length < 7) {
          weekChildren.add(Container());
        }
        rows.add(TableRow(children: weekChildren));
      }
      return rows;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            DateFormat.MMMM('de_DE').format(month),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Table(
          children: buildCalendarRows(),
        ),
      ],
    );
  }
}