import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekView extends StatelessWidget {
  final DateTime focusedDay;

  const WeekView({super.key, required this.focusedDay});

  List<DateTime> _getWeekDays(DateTime day) {
    DateTime startOfWeek = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(focusedDay);
    final headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 60), // Spacer for time column
            ...weekDays.map(
              (day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day).substring(0, 3),
                        style: headerStyle,
                      ), // e.g., 'Mon'
                      Text(day.day.toString(), style: headerStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: 24, // 24 hours
            itemBuilder: (context, hour) {
              return SizedBox(
                height: 60,
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text('${hour.toString().padLeft(2, '0')}:00'),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: const BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                  left: dayIndex == 0
                                      ? BorderSide.none
                                      : const BorderSide(
                                          color: Colors.grey,
                                          width: 0.5,
                                        ),
                                ),
                              ),
                              child:
                                  const SizedBox.shrink(), // Placeholder for events
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
