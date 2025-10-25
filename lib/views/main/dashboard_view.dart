import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/dialogs/person_editor_dialog.dart';
import 'package:myapp/dialogs/user_editor_dialog.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/calendar.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/views/settings/settings_view.dart';

// Top-level function for compute
User _loadUserData(String _) {
  // This is where you would do your heavy lifting, e.g., from a database or network.
  // We add a delay to simulate a long-running operation.
  // In a real app, you would not have this delay.
  // Future.delayed(const Duration(seconds: 2)); // This doesn't work with compute

  // Let's just return the data for now.
  return User(
    person: Person(fullName: 'John Doe', dateOfBirth: DateTime(1990, 1, 1)),
    contacts: [
      Person(fullName: 'Jane Smith', dateOfBirth: DateTime(1992, 5, 10)),
      Person(fullName: 'Peter Jones', dateOfBirth: DateTime(1988, 11, 22)),
    ],
    calendar: Calendar(appointments: [
      Appointment(
        title: 'Meeting with team',
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 1)),
      ),
      Appointment(
        title: 'Lunch with Jane',
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 1, hours: 1)),
      ),
    ]),
  );
}

class DashboardView extends StatefulWidget {
  final Function(Widget Function(ScrollController)) showAsModalSheet;
  const DashboardView({super.key, required this.showAsModalSheet});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    LoadingService().show();
    final user = await compute(_loadUserData, '');
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
    LoadingService().hide();
  }

  void _showDetailView(int index) {
    widget.showAsModalSheet((scrollController) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildCardByIndex(index, isInModal: true),
        ),
      );
    });
  }

  void _showToast(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                scaffold.hideCurrentSnackBar();
                // This navigation is now handled by the main screen's modal
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _openAddDialog(String title, dynamic data) {
    switch (title) {
      case 'Users':
        showDialog(
          context: context,
          builder: (context) => UserEditorDialog(
            onSave: (updatedPerson) {
              setState(() {
                _user = User(
                  person: updatedPerson,
                  contacts: _user!.contacts,
                  calendar: _user!.calendar,
                );
              });
              _showToast('User added');
            },
          ),
        );
        break;
      case 'People':
        showDialog(
          context: context,
          builder: (context) => PersonEditorDialog(
            onSave: (newPerson) {
              setState(() {
                _user!.contacts.add(newPerson);
              });
              _showToast('Person added');
            },
          ),
        );
        break;
      case 'Calendar':
        showDialog(
          context: context,
          builder: (context) => AppointmentEditorDialog(
            onSave: (newAppointment) {
              setState(() {
                _user!.calendar.appointments.add(newAppointment);
              });
              _showToast('Appointment added');
            },
          ),
        );
        break;
    }
  }

  void _openEditDialog(String title, dynamic item) {
    switch (title) {
      case 'Users':
        showDialog(
          context: context,
          builder: (context) => UserEditorDialog(
            onSave: (updatedPerson) {
              setState(() {
                _user = User(
                  person: updatedPerson,
                  contacts: _user!.contacts,
                  calendar: _user!.calendar,
                );
              });
              _showToast('User updated');
            },
          ),
        );
        break;
      case 'People':
        showDialog(
          context: context,
          builder: (context) => PersonEditorDialog(
            person: item,
            onSave: (updatedPerson) {
              setState(() {
                final index = _user!.contacts.indexOf(item);
                _user!.contacts[index] = updatedPerson;
              });
              _showToast('Person updated');
            },
          ),
        );
        break;
      case 'Calendar':
        showDialog(
          context: context,
          builder: (context) => AppointmentEditorDialog(
            appointment: item,
            onSave: (updatedAppointment) {
              setState(() {
                final index = _user!.calendar.appointments.indexOf(item);
                _user!.calendar.appointments[index] = updatedAppointment;
              });
              _showToast('Appointment updated');
            },
          ),
        );
        break;
    }
  }

  Future<void> _showDeleteConfirmationDialog(String title, dynamic item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${title.substring(0, title.length - 1)}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  if (item is Person) {
                    _user!.contacts.remove(item);
                  } else if (item is Appointment) {
                    _user!.calendar.appointments.remove(item);
                  }
                });
                Navigator.of(context).pop();
                _showToast('Item deleted');
              },
            ),
          ],
        );
      },
    );
  }

  void _showViewDialog(String title, dynamic item) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title.substring(0, title.length - 1)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getViewDetails(item),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        });
    _showToast('Viewed item');
  }

  List<Widget> _getViewDetails(dynamic item) {
    if (item is Person) {
      return [
        Text('Name: ${item.fullName}'),
        Text('Date of Birth: ${item.dateOfBirth.toIso8601String().substring(0, 10)}'),
      ];
    } else if (item is Appointment) {
      return [
        Text('Title: ${item.title}'),
        Text('Description: ${item.description}'),
        Text('Start: ${item.start.toIso8601String().substring(0, 16)}'),
        Text('End: ${item.end.toIso8601String().substring(0, 16)}'),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const SizedBox.shrink(); // Or a placeholder
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        buildCardByIndex(0),
        buildCardByIndex(1),
        buildCardByIndex(2),
      ],
    );
  }

  Widget buildCardByIndex(int idx, {bool isInModal = false}) {
    switch (idx) {
      case 0:
        return _buildModelCard(0, context, 'Users', _user!, [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('date of birth')),
          const DataColumn(label: Text('')),
        ], isInModal: isInModal);
      case 1:
        return _buildModelCard(1, context, 'People', _user!.contacts, [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('date of birth')),
          const DataColumn(label: Text('')),
        ], isInModal: isInModal);
      case 2:
      default:
        return _buildModelCard(2, context, 'Calendar', _user!.calendar.appointments, [
          const DataColumn(label: Text('Title')),
          const DataColumn(label: Text('Date')),
          const DataColumn(label: Text('')),
        ], isInModal: isInModal);
    }
  }

  Widget _buildModelCard(int index, BuildContext context, String title, dynamic data,
      List<DataColumn> columns, {bool isInModal = false}) {
    return Card(
      margin: isInModal ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: Theme.of(context).textTheme.titleLarge),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _openAddDialog(title, data),
                  ),
                  if (!isInModal)
                    IconButton(
                      icon: const Icon(Icons.open_in_full),
                      onPressed: () => _showDetailView(index),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: columns,
                rows: _getRows(data, title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _getRows(dynamic data, String title) {
    if (data is User) {
      return [
        DataRow(cells: [
          DataCell(Text(data.person.fullName)),
          DataCell(Text(data.person.dateOfBirth.toIso8601String().substring(0, 10))),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openEditDialog(title, data.person),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: null, // Deleting user is not allowed
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showViewDialog(title, data.person),
                ),
              ],
            ),
          ),
        ])
      ];
    } else if (data is List<Person>) {
      return data.map((person) {
        return DataRow(cells: [
          DataCell(Text(person.fullName)),
          DataCell(Text(person.dateOfBirth.toIso8601String().substring(0, 10))),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openEditDialog(title, person),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(title, person),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showViewDialog(title, person),
                ),
              ],
            ),
          ),
        ]);
      }).toList();
    } else if (data is List<Appointment>) {
      return data.map((appointment) {
        return DataRow(cells: [
          DataCell(Text(appointment.title)),
          DataCell(Text(appointment.start.toIso8601String().substring(0, 10))),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openEditDialog(title, appointment),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(title, appointment),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showViewDialog(title, appointment),
                ),
              ],
            ),
          ),
        ]);
      }).toList();
    }
    return [];
  }
}
