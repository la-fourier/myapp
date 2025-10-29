import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/calendar/appointment.dart';

class TodayView extends StatelessWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.loggedInUser;
        if (user == null) {
          return const Center(child: Text('No user logged in.'));
        }

        final now = DateTime.now();
        final todayAppointments = user.calendar.appointments.where((app) {
          return app.start.year == now.year &&
              app.start.month == now.month &&
              app.start.day == now.day;
        }).toList();

        // Group appointments by hour
        final Map<int, List<Appointment>> appointmentsByHour = {};
        for (final appointment in todayAppointments) {
          final hour = appointment.start.hour;
          if (appointmentsByHour[hour] == null) {
            appointmentsByHour[hour] = [];
          }
          appointmentsByHour[hour]!.add(appointment);
        }

        return ListView.builder(
          itemCount: 24,
          itemBuilder: (context, index) {
            final hour = index;
            final appointmentsInHour = appointmentsByHour[hour] ?? [];

            return TimeSlot(hour: hour, appointments: appointmentsInHour);
          },
        );
      },
    );
  }
}

class TimeSlot extends StatelessWidget {
  final int hour;
  final List<Appointment> appointments;

  const TimeSlot({super.key, required this.hour, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: appointments.isEmpty
                ? Container(
                    height: 50, // Height for an empty slot
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: const Center(
                      child: Text('No appointments', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: appointments.map((appointment) {
                      return AppointmentCard(appointment: appointment);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.Hm(); // HH:mm format

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${timeFormat.format(appointment.start)} - ${timeFormat.format(appointment.end)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (appointment.description != null && appointment.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(appointment.description!),
              ),
          ],
        ),
      ),
    );
  }
}