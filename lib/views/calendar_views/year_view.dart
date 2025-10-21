import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearView extends StatelessWidget {
  final DateTime focusedDay;

  const YearView({super.key, required this.focusedDay});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 months per row
        childAspectRatio: 1.5, // Adjust for better spacing
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = DateTime(focusedDay.year, index + 1);
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              DateFormat.MMM().format(month), // e.g., Jan, Feb
              style: TextStyle(fontSize: 18, color: textColor),
            ),
          ),
        );
      },
    );
  }
}
