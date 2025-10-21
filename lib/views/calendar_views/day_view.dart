
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayView extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onBack;

  const DayView({
    super.key,
    required this.selectedDay,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
          tooltip: 'Back to Calendar',
        ),
        title: Text(DateFormat('MMMM d, yyyy').format(selectedDay)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Events for ${DateFormat.yMd().format(selectedDay)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const Text('// TODO: Display a list of events here.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement functionality to add a new event.
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
