import 'package:flutter/material.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';
import 'package:myapp/dialogs/person_editor_dialog.dart';
import 'package:myapp/dialogs/user_editor_dialog.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar.dart';
import 'package:myapp/models/appointment.dart';
import 'package:myapp/views/toast_settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? _zoomedIndex;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = User(
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

  void _setZoomedIndex(int? index) {
    setState(() {
      _zoomedIndex = index;
    });
    if (index != null) {
      _showToast('Zoomed in');
    }
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ToastSettingsView()),
                );
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
                  contacts: _user.contacts,
                  calendar: _user.calendar,
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
                _user.contacts.add(newPerson);
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
                _user.calendar.appointments.add(newAppointment);
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
                  contacts: _user.contacts,
                  calendar: _user.calendar,
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
                final index = _user.contacts.indexOf(item);
                _user.contacts[index] = updatedPerson;
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
                final index = _user.calendar.appointments.indexOf(item);
                _user.calendar.appointments[index] = updatedAppointment;
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
                    _user.contacts.remove(item);
                  } else if (item is Appointment) {
                    _user.calendar.appointments.remove(item);
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
    Widget buildCardByIndex(int idx) {
      switch (idx) {
        case 0:
          return _buildModelCard(0, context, 'Users', _user, [
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('date of birth')),
          ]);
        case 1:
          return _buildModelCard(1, context, 'People', _user.contacts, [
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('date of birth')),
          ]);
        case 2:
        default:
          return _buildModelCard(2, context, 'Calendar', _user.calendar.appointments, [
            const DataColumn(label: Text('Title')),
            const DataColumn(label: Text('Date')),
          ]);
      }
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            buildCardByIndex(0),
            buildCardByIndex(1),
            buildCardByIndex(2),
          ],
        ),
        if (_zoomedIndex != null)
          GestureDetector(
            onTap: () => _setZoomedIndex(null),
            child: Container(
              color: Colors.black.withAlpha(128),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: buildCardByIndex(_zoomedIndex!),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _setZoomedIndex(null),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModelCard(int index, BuildContext context, String title, dynamic data, List<DataColumn> columns) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  IconButton(
                    icon: const Icon(Icons.open_in_full),
                    onPressed: () => _setZoomedIndex(index),
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
