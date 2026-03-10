import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/views/calendar/calendar_view.dart';

class SharedCalendarView extends StatelessWidget {
  final String? contactUid;
  final String? credibility;
  final String? encodedData;

  const SharedCalendarView({super.key, this.contactUid, this.credibility, this.encodedData});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;

    List<Appointment> appointments = [];
    String cred = 'unknown';
    String contactUidLocal = '';

    if (encodedData != null) {
      try {
        final decoded = jsonDecode(utf8.decode(base64Decode(encodedData!)));
        appointments = (decoded['appointments'] as List).map((a) => Appointment.fromJson(a)).toList();
        cred = decoded['credibility'];
        contactUidLocal = decoded['contactUid'];
      } catch (e) {
        return const Scaffold(body: Center(child: Text('Invalid shared data')));
      }
    } else if (user != null && contactUid != null) {
      final contact = user.contacts.firstWhere(
        (c) => c.uid == contactUid,
        orElse: () => Person(uid: '', fullName: '', dateOfBirth: DateTime.now()),
      );
      appointments = user.calendar.appointments;
      cred = credibility ?? 'unknown';
      contactUidLocal = contactUid!;
    } else {
      return const Scaffold(body: Center(child: Text('Shared calendar not available')));
    }

    final contact = Person(uid: contactUidLocal, fullName: 'Shared Contact', dateOfBirth: DateTime.now());

    Widget content;
    switch (cred.toLowerCase()) {
      case 'family':
        content = CalendarView(onDaySelected: (date) {}); // Full calendar, but with shared data?
        break;
      case 'friend':
        content = AnonymizedCalendarView(appointments: appointments, contact: contact);
        break;
      case 'colleague':
        content = AvailabilityCalendarView(appointments: appointments, contact: contact);
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
  final List<Appointment> appointments;
  final Person contact;

  const AnonymizedCalendarView({super.key, required this.appointments, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
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
  final List<Appointment> appointments;
  final Person contact;

  const AvailabilityCalendarView({super.key, required this.appointments, required this.contact});

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