import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/dialogs/read_views/appointment_read_view.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:provider/provider.dart';

class WeekView extends StatefulWidget {
  final DateTime focusedDay;

  const WeekView({super.key, required this.focusedDay});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late DateTime _currentWeek;
  late Timer _timer;
  Offset _hoverPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _currentWeek = _getMonday(widget.focusedDay);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {}); // Redraw to update the time indicator
      }
    });
  }

  @override
  void didUpdateWidget(WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(
      _getMonday(widget.focusedDay),
      _getMonday(oldWidget.focusedDay),
    )) {
      setState(() {
        _currentWeek = _getMonday(widget.focusedDay);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    });
  }

  void _showAppointmentEditor(DateTime startTime) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AppointmentEditorDialog(
        startTime: startTime,
        onSave: (appointment) {
          Provider.of<AppState>(
            context,
            listen: false,
          ).loggedInUser?.calendar.appointments.add(appointment);
        },
      ),
    );
  }

  void _showAppointmentEditorForEditing(Appointment appointment) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AppointmentEditorDialog(
        appointment: appointment,
        onSave: (newAppointment) {
          final userCalendar = Provider.of<AppState>(
            context,
            listen: false,
          ).loggedInUser?.calendar;
          if (userCalendar != null) {
            final index = userCalendar.appointments.indexOf(appointment);
            if (index != -1) {
              userCalendar.appointments[index] = newAppointment;
            }
          }
        },
      ),
    );
  }

  DateTime _calculateHoverTime(
    Offset position,
    double dayWidth,
    List<DateTime> weekDays,
    double hourHeight,
    double timeColWidth,
  ) {
    final dx = position.dx - timeColWidth;
    final dy = position.dy;
    if (dx < 0) return DateTime.now();

    final dayIndex = (dx / dayWidth).floor();
    if (dayIndex < 0 || dayIndex >= 7) return DateTime.now();

    final quarterHour = (dy / (hourHeight / 4)).floor();
    final hour = (quarterHour / 4).floor();
    final minute = (quarterHour % 4) * 15;

    final weekDay = weekDays[dayIndex];
    return DateTime(weekDay.year, weekDay.month, weekDay.day, hour, minute);
  }

  Widget _buildHoverIndicator(
    double dayWidth,
    double hourHeight,
    double timeColWidth,
    List<DateTime> weekDays,
  ) {
    final hoverTime = _calculateHoverTime(
      _hoverPosition,
      dayWidth,
      weekDays,
      hourHeight,
      timeColWidth,
    );
    if (hoverTime == null) return const SizedBox.shrink();

    final dayIndex = hoverTime.weekday - 1;
    final top =
        (hoverTime.hour * hourHeight) + (hoverTime.minute / 60 * hourHeight);
    final left = timeColWidth + (dayIndex * dayWidth);

    return Positioned(
      top: top,
      left: left,
      width: dayWidth - 2,
      height: hourHeight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.0),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Icon(Icons.add_circle_outline, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeIndicator(
    double dayWidth,
    double hourHeight,
    double timeColWidth,
  ) {
    final now = DateTime.now();
    if (now.isBefore(_currentWeek) ||
        now.isAfter(_currentWeek.add(const Duration(days: 7)))) {
      return const SizedBox.shrink();
    }
    final dayIndex = now.weekday - 1;
    final top = (now.hour * hourHeight) + (now.minute / 60 * hourHeight);
    final left = timeColWidth + (dayIndex * dayWidth);

    return Positioned(
      top: top,
      left: left,
      width: dayWidth,
      child: Container(height: 2, color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final appointments = appState.loggedInUser?.calendar.appointments ?? [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final arrowColor = isDarkMode ? Colors.white : Colors.black;
    final weekDays = List.generate(
      7,
      (index) => _currentWeek.add(Duration(days: index)),
    );

    const double hourHeight = 60.0;
    const double timeColWidth = 50.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            _buildMonthHeader(arrowColor),
            _buildWeekHeader(weekDays, timeColWidth),
            Expanded(
              child: SingleChildScrollView(
                child: MouseRegion(
                  onHover: (event) =>
                      setState(() => _hoverPosition = event.localPosition),
                  onExit: (event) =>
                      setState(() => _hoverPosition = Offset.zero),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final dayWidth =
                          (constraints.maxWidth - timeColWidth) / 7;
                      return GestureDetector(
                        onDoubleTapDown: (details) {
                          final hoverTime = _calculateHoverTime(
                            details.localPosition,
                            dayWidth,
                            weekDays,
                            hourHeight,
                            timeColWidth,
                          );
                          if (hoverTime != null) {
                            _showAppointmentEditor(hoverTime);
                          }
                        },
                        child: Stack(
                          children: [
                            _buildTimeGrid(hourHeight, timeColWidth),
                            ..._buildAppointments(
                              appointments,
                              dayWidth,
                              hourHeight,
                              timeColWidth,
                            ),
                            if (_hoverPosition != Offset.zero) ...[
                              _buildHoverIndicator(
                                dayWidth,
                                hourHeight,
                                timeColWidth,
                                weekDays,
                              ),
                            ],
                            _buildCurrentTimeIndicator(
                              dayWidth,
                              hourHeight,
                              timeColWidth,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(Color arrowColor) {
    final weekNumber = _getWeekNumber(_currentWeek);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: _previousWeek,
            isLeft: true,
          ),
          Text(
            '${DateFormat.yMMMM().format(_currentWeek)} - CW $weekNumber',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: _nextWeek,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(30) : Radius.zero,
          right: !isLeft ? const Radius.circular(30) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(30) : Radius.zero,
              right: !isLeft ? const Radius.circular(30) : Radius.zero,
            ),
          ),
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDays, double timeColWidth) {
    return Padding(
      padding: EdgeInsets.only(left: timeColWidth),
      child: Row(
        children: List.generate(7, (index) {
          final day = weekDays[index];
          return Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    DateFormat.E().format(day),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    DateFormat.d().format(day),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeGrid(double hourHeight, double timeColWidth) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final horizontalLineColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade400;
    final verticalLineColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    return Row(
      children: [
        _TimeColumn(hourHeight: hourHeight, timeColWidth: timeColWidth),
        Expanded(
          child: Column(
            children: List.generate(24, (hour) {
              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: horizontalLineColor, width: 0.5),
                  ),
                ),
                child: Row(
                  children: List.generate(7, (day) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: verticalLineColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppointments(
    List<Appointment> appointments,
    double dayWidth,
    double hourHeight,
    double timeColWidth,
  ) {
    return appointments
        .where((app) {
          final weekEnd = _currentWeek.add(const Duration(days: 7));
          return app.start.isBefore(weekEnd) && app.end.isAfter(_currentWeek);
        })
        .map((app) {
          final dayIndex = app.start.weekday - 1;
          final top =
              (app.start.hour * hourHeight) +
              (app.start.minute / 60 * hourHeight);
          final left = timeColWidth + (dayIndex * dayWidth);
          final height =
              app.end.difference(app.start).inMinutes / 60 * hourHeight;

          return Positioned(
            top: top,
            left: left,
            width: dayWidth - 2, // Margin
            height: height,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AppointmentReadView(
                    appointment: app,
                    onEdit: () {
                      Navigator.pop(context);
                      _showAppointmentEditorForEditing(app);
                    },
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(1.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: app.category.color.withAlpha(204),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  app.title,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        })
        .toList();
  }

}

class _TimeColumn extends StatelessWidget {
  final double hourHeight;
  final double timeColWidth;

  const _TimeColumn({required this.hourHeight, required this.timeColWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: timeColWidth,
      child: Column(
        children: List.generate(24, (index) {
          return Container(
            height: hourHeight,
            padding: const EdgeInsets.only(right: 4.0),
            alignment: Alignment.topRight,
            child: Text(
              '${index.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 10),
            ),
          );
        }),
      ),
    );
  }
}
