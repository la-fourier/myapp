import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

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

  void _showAppointmentEditor(
    BuildContext context,
    AppState appState, [
    Appointment? appointment,
  ]) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditorDialog(
        appointment: appointment,
        startTime: selectedDay,
        onSave: (newAppointment) {
          if (appointment != null) {
            appState.updateItem<Appointment>(appointment, newAppointment);
          } else {
            appState.addItem<Appointment>(newAppointment);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final appointments =
        appState.loggedInUser?.calendar.appointments
            .where(
              (app) =>
                  app.start.year == selectedDay.year &&
                  app.start.month == selectedDay.month &&
                  app.start.day == selectedDay.day,
            )
            .toList() ??
        [];

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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onBack,
                tooltip: 'Close',
              ),
            ],
            backgroundColor: Colors.transparent, // Make AppBar transparent
            elevation: 0,
          ),
        ];
      },
      body: Scaffold(
        body: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return ListTile(
              leading: Container(width: 5, color: appointment.category.color),
              title: Text(appointment.title),
              subtitle: Text(
                '${DateFormat.jm().format(appointment.start)} - ${DateFormat.jm().format(appointment.end)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showAppointmentEditor(context, appState, appointment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => appState.deleteItem<Appointment>(appointment),
                  ),
                ],
              ),
              onTap: () =>
                  _showAppointmentEditor(context, appState, appointment),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAppointmentEditor(context, appState),
          tooltip: 'Add Event',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
