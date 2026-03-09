import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/views/calendar/calendar_view.dart';

class SharedCalendarView extends StatelessWidget {
  final String contactUid;
  final String credibility;

  const SharedCalendarView({super.key, required this.contactUid, required this.credibility});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    final contact = user.contacts.firstWhere(
      (c) => c.uid == contactUid,
      orElse: () => Person(uid: '', fullName: '', dateOfBirth: DateTime.now()),
    );

    if (contact.uid.isEmpty) {
      return const Scaffold(body: Center(child: Text('Contact not found')));
    }

    Widget content;
    switch (credibility.toLowerCase()) {
      case 'family':
        content = CalendarView(onDaySelected: (date) {}); // Full calendar
        break;
      case 'friend':
        content = AnonymizedCalendarView(user: user, contact: contact);
        break;
      case 'colleague':
        content = AvailabilityCalendarView(user: user, contact: contact);
        break;
      default:
        content = const Center(child: Text('Invalid credibility level'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared Calendar with ${contact.fullName}'),
      ),
      body: content,
    );
  }
}

class AnonymizedCalendarView extends StatelessWidget {
  final User user;
  final Person contact;

  const AnonymizedCalendarView({super.key, required this.user, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: user.calendar.appointments.length,
      itemBuilder: (context, index) {
        final appointment = user.calendar.appointments[index];
        return ListTile(
          title: Text('Appointment ${index + 1}'),
          subtitle: Text('Priority: ${appointment.priority ?? 'N/A'}'),
          tileColor: Colors.grey.withOpacity(0.5), // Grayed out
        );
      },
    );
  }
}

class AvailabilityCalendarView extends StatelessWidget {
  final User user;
  final Person contact;

  const AvailabilityCalendarView({super.key, required this.user, required this.contact});

  @override
  Widget build(BuildContext context) {
    // Simple availability view
    return Column(
      children: [
        const Text('Available times:'),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Monday 10:00 - 12:00'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Request appointment
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment requested!')),
                    );
                  },
                  child: const Text('Request'),
                ),
              ),
              // Add more slots
            ],
          ),
        ),
      ],
    );
  }
}