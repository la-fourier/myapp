import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/services/theme_provider.dart';
import 'package:provider/provider.dart';

class DayView extends StatefulWidget {
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
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final TextEditingController _queryController = TextEditingController();
  List<Appointment> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_filterAppointments);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterAppointments();
  }

  @override
  void dispose() {
    _queryController.removeListener(_filterAppointments);
    _queryController.dispose();
    super.dispose();
  }

  void _filterAppointments() {
    final appState = Provider.of<AppState>(context, listen: false);
    final allAppointments =
        appState.loggedInUser?.calendar.appointments
            .where(
              (app) =>
                  app.start.year == widget.selectedDay.year &&
                  app.start.month == widget.selectedDay.month &&
                  app.start.day == widget.selectedDay.day,
            )
            .toList() ??
        [];

    final query = _queryController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredAppointments = allAppointments;
      });
      return;
    }

    setState(() {
      _filteredAppointments = allAppointments.where((appointment) {
        return appointment.title.toLowerCase().contains(query) ||
            (appointment.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _showAppointmentEditor(
    BuildContext context,
    AppState appState, [
    Appointment? appointment,
  ]) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditorDialog(
        appointment: appointment,
        startTime: widget.selectedDay,
        onSave: (newAppointment) {
          if (appointment != null) {
            Provider.of<AppState>(
              context,
              listen: false,
            ).loggedInUser?.calendar.appointments.remove(appointment);
            appState.loggedInUser?.calendar.appointments.add(newAppointment);
          } else {
            appState.loggedInUser?.calendar.appointments.add(newAppointment);
          }
          _filterAppointments(); // Refresh list after save
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // We call this here to ensure the list is up-to-date if the appointments in AppState change
    _filterAppointments();

    return NestedScrollView(
      controller: widget.scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false, // No back button
            title: Text(
              DateFormat('MMMM d, yyyy').format(widget.selectedDay),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onBack,
                tooltip: 'Close',
              ),
            ],
            backgroundColor: Colors.transparent, // Make AppBar transparent
            elevation: 0,
          ),
        ];
      },
      body: Scaffold(
        body: Column(
          children: [
            if (themeProvider.showQueryField)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Filter appointments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                primary: false,
                itemCount: _filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _filteredAppointments[index];
                  return ListTile(
                    leading: Container(
                      width: 5,
                      color: appointment.category.color,
                    ),
                    title: Text(appointment.title),
                    subtitle: Text(
                      '${DateFormat.jm().format(appointment.start)} - ${DateFormat.jm().format(appointment.end)}',
                    ),
                    trailing: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 120) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showAppointmentEditor(
                                  context,
                                  appState,
                                  appointment,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Provider.of<AppState>(context, listen: false)
                                      .loggedInUser
                                      ?.calendar
                                      .appointments
                                      .remove(appointment);
                                  _filterAppointments(); // Refresh list after delete
                                },
                              ),
                            ],
                          );
                        } else {
                          return PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAppointmentEditor(
                                  context,
                                  appState,
                                  appointment,
                                );
                              } else if (value == 'delete') {
                                Provider.of<AppState>(context, listen: false)
                                    .loggedInUser
                                    ?.calendar
                                    .appointments
                                    .remove(appointment);
                                _filterAppointments(); // Refresh list after delete
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                    ),
                                  ),
                                ],
                          );
                        }
                      },
                    ),
                    onTap: () =>
                        _showAppointmentEditor(context, appState, appointment),
                  );
                },
              ),
            ),
          ],
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
