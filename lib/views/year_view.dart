import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatefulWidget {
  final void Function(DateTime) onDaySelected;

  const YearView({super.key, required this.onDaySelected});

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
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = DateTime(_currentYear.year, index + 1);
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                       color: Colors.grey.withOpacity(0.2),
                       spreadRadius: 1,
                       blurRadius: 3,
                       offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: _MonthCalendar(
                  month: month,
                  onDaySelected: widget.onDaySelected,
                ),
              );
            },
          ),
        ),
      ],
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

    final List<String> weekdayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    List<TableRow> buildCalendarRows() {
      final List<TableRow> rows = [];
      List<Widget> weekChildren = [];

      // Header Row
      rows.add(TableRow(
        children: weekdayNames.map((name) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        )).toList(),
      ));

      // Day Rows
      for (int i = 1; i < firstWeekday; i++) {
        weekChildren.add(Container());
      }

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        weekChildren.add(
          InkWell(
            onTap: () => onDaySelected(date),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
          child: Text(
            DateFormat.MMMM().format(month),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Table(
            children: buildCalendarRows(),
          ),
        ),
      ],
    );
  }
}
