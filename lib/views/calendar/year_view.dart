import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:myapp/widgets/pie_chart_painter.dart';
import 'package:provider/provider.dart';

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
    // Use LayoutBuilder to adapt how many month cards are shown per row
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      // Determine crossAxisCount based on available width. For small screens show 2, medium 3, large 4.
      int crossAxisCount;
      if (maxWidth < 600) {
        crossAxisCount = 2;
      } else if (maxWidth < 1000) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 4;
      }

      // Compute card width to help scale fonts inside month cards
      final double cardWidth = (maxWidth - (crossAxisCount - 1) * 8) / crossAxisCount;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = DateTime(widget.focusedDay.year, index + 1);
          return _buildMonth(context, month, cardWidth);
        },
      );
    });
  }

  Widget _buildMonth(BuildContext context, DateTime month, double cardWidth) {
    // Derive font sizes from available card width
    final double monthTitleSize = (cardWidth * 0.09).clamp(12.0, 20.0);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat.MMMM().format(month),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: monthTitleSize,
                  ),
            ),
          ),
          Expanded(
            child: _buildMonthGrid(month, cardWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month, double cardWidth) {
    final appState = Provider.of<AppState>(context);
    final appointments = appState.loggedInUser?.calendar.appointments ?? [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1).weekday;
    final List<Widget> dayWidgets = [];
    final Color subtleTextColor = (isDarkMode ? Colors.white : Colors.black).withAlpha(128);

    // Compute cell font size based on card width. There are 7 columns; reserve padding.
    final double effectiveCellWidth = (cardWidth - 16) / 7.0;
    final double cellFontSize = (effectiveCellWidth * 0.35).clamp(8.0, 16.0);

    // Add weekday headers
    for (var day in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) {
      dayWidgets.add(
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.normal, color: subtleTextColor, fontSize: cellFontSize * 0.9),
            ),
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
      final hasAppointment = appointments.any((app) => isSameDay(app.start, day));

      dayWidgets.add(
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredDay = day),
          onExit: (_) => setState(() => _hoveredDay = null),
          child: GestureDetector(
            onTap: () => widget.onDaySelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: isHovered ? Matrix4.diagonal3Values(1.05, 1.05, 1.0) : Matrix4.identity(),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday
                    ? Theme.of(context).colorScheme.tertiary.withAlpha(128)
                    : (isHovered ? Theme.of(context).hoverColor : Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: cellFontSize,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (hasAppointment)
                    Positioned(
                      bottom: 4,
                      child: CustomPaint(
                        painter: PieChartPainter(
                          colors: appointments
                              .where((app) => isSameDay(app.start, day))
                              .map((e) => e.category.color)
                              .toList(),
                        ),
                        size: const Size(8, 8),
                      ),
                    ),
                ],
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