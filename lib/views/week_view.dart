import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekView extends StatefulWidget {
  final DateTime focusedDay;

  const WeekView({super.key, required this.focusedDay});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late DateTime _focusedDay;
  late Timer _timer;
  DateTime _now = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;

    // Scroll to the current time of day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final timeFraction = (now.hour + now.minute / 60.0);
      final scrollTo = timeFraction * 60.0 - (MediaQuery.of(context).size.height / 3);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(scrollTo > 0 ? scrollTo : 0);
      }
    });

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _previousWeek() {
    setState(() {
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _focusedDay = _focusedDay.add(const Duration(days: 7));
    });
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  List<DateTime> _getWeekDays(DateTime day) {
    DateTime startOfWeek = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_focusedDay);
    final headerStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    const hourHeight = 60.0;
    const timeColumnWidth = 60.0;

    final todayDayIndex = weekDays.indexWhere((day) => DateUtils.isSameDay(day, _now));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousWeek,
              ),
              Text(
                'week ${_getWeekNumber(_focusedDay)}, ${DateFormat.y().format(_focusedDay)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextWeek,
              ),
            ],
          ),
        ),
        // Header Row
        Row(
          children: [
            const SizedBox(width: timeColumnWidth), // Spacer for time column
            ...weekDays.asMap().entries.map((entry) {
              final DateTime day = entry.value;
              final bool isToday = DateUtils.isSameDay(day, _now);

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE').format(day),
                        style: headerStyle?.copyWith(
                            color: isToday ? Theme.of(context).primaryColor : null),
                      ),
                      Text(
                        day.day.toString(),
                        style: headerStyle?.copyWith(
                            color: isToday ? Theme.of(context).primaryColor : null),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dayWidth = (constraints.maxWidth - timeColumnWidth) / 7;
                return Stack(
                  children: [
                    // Grid lines painter
                    CustomPaint(
                      size: Size(constraints.maxWidth, hourHeight * 24),
                      painter: _GridPainter(hourHeight: hourHeight, dayWidth: dayWidth, timeColumnWidth: timeColumnWidth),
                    ),

                    // Time labels
                    ...List.generate(24, (hour) {
                      return Positioned(
                        top: hour * hourHeight - 7,
                        left: 0,
                        child: Container(
                          width: timeColumnWidth,
                          height: 14,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    // Red "Current Time" Indicator
                    if (todayDayIndex != -1)
                      Positioned(
                        top: (_now.hour * hourHeight) + _now.minute,
                        left: timeColumnWidth + (todayDayIndex * dayWidth),
                        width: dayWidth,
                        child: Container(
                          height: 2.0,
                          color: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double hourHeight;
  final double dayWidth;
  final double timeColumnWidth;

  _GridPainter({required this.hourHeight, required this.dayWidth, required this.timeColumnWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw horizontal lines
    for (int i = 0; i <= 24; i++) {
      final y = i * hourHeight;
      canvas.drawLine(Offset(timeColumnWidth, y), Offset(size.width, y), linePaint);
    }

    // Draw vertical lines
    for (int i = 1; i < 7; i++) {
      final x = timeColumnWidth + i * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
