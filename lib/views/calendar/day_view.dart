import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayView extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onBack;
  final ScrollController? scrollController; // Optional scroll controller

  const DayView({
    super.key,
    required this.selectedDay,
    required this.onBack,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false, // No back button
            title: Text(
              DateFormat('MMMM d, yyyy').format(selectedDay),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onBack,
                tooltip: 'Close',
              )
            ],
            backgroundColor: Colors.transparent, // Make AppBar transparent
            elevation: 0,
          ),
        ];
      },
      body: Scaffold(
        body: ListView(
          // The controller is now on the NestedScrollView
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Events for ${DateFormat.yMd().format(selectedDay)}',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('// TODO: Display a list of events here.'),
                  // Add more content to make it scrollable
                  for (int i = 0; i < 20; i++)
                    ListTile(
                      leading: Icon(Icons.event, color: theme.colorScheme.secondary),
                      title: Text('Event ${i + 1}'),
                      subtitle: Text('Details for event ${i + 1}'),
                      onTap: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement functionality to add a new event.
          },
          tooltip: 'Add Event',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}