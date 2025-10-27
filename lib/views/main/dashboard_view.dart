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

// Top-level function for compute
User _loadUserData(String _) {
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
  List<Map<String, dynamic>> _columnLeft = [];
  List<Map<String, dynamic>> _columnRight = [];

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
        _initializeCards();
      });
    }
    LoadingService().hide();
  }

  void _initializeCards() {
    if (_user == null) return;
    final allCards = [
      {
        'id': 'users',
        'title': 'Users',
        'data': _user!,
        'columns': [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Date of Birth')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'people',
        'title': 'People',
        'data': _user!.contacts,
        'columns': [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Date of Birth')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'calendar',
        'title': 'Calendar',
        'data': _user!.calendar.appointments,
        'columns': [
          const DataColumn(label: Text('Title')),
          const DataColumn(label: Text('Date')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'tasks',
        'title': 'Tasks',
        'data': [Appointment(title: 'Buy groceries', start: DateTime.now(), end: DateTime.now())],
        'columns': [
          const DataColumn(label: Text('Task')),
          const DataColumn(label: Text('Due Date')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'notes',
        'title': 'Notes',
        'data': [Person(fullName: 'Remember to call mom', dateOfBirth: DateTime.now())], // Using Person as dummy data
        'columns': [
          const DataColumn(label: Text('Note')),
          const DataColumn(label: Text('Created')),
          const DataColumn(label: Text('')),
        ],
      },
    ];

    // Distribute cards into two columns
    _columnLeft = [];
    _columnRight = [];
    for (int i = 0; i < allCards.length; i++) {
      if (i.isEven) {
        _columnLeft.add(allCards[i]);
      } else {
        _columnRight.add(allCards[i]);
      }
    }
  }

  void _onReorder(List<Map<String, dynamic>> column, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = column.removeAt(oldIndex);
      column.insert(newIndex, item);
    });
  }

  void _showDetailView(Map<String, dynamic> cardData) {
    widget.showAsModalSheet((scrollController) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildModelCard(cardData, context, 0, isInModal: true),
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
                _initializeCards();
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
                _initializeCards();
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
                _initializeCards();
              });
              _showToast('Appointment added');
            },
          ),
        );
        break;
      default:
        _showToast('Add action not available for this card type.');
    }
  }

  void _openEditDialog(String title, dynamic item) {
    switch (title) {
      case 'Users':
      case 'People':
        showDialog(
          context: context,
          builder: (context) => PersonEditorDialog(
            person: item,
            onSave: (updatedPerson) {
              setState(() {
                if (item is User) {
                  _user = User(
                    person: updatedPerson,
                    contacts: _user!.contacts,
                    calendar: _user!.calendar,
                  );
                } else {
                  final index = _user!.contacts.indexOf(item);
                  _user!.contacts[index] = updatedPerson;
                }
                _initializeCards();
              });
              _showToast('Item updated');
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
                _initializeCards();
              });
              _showToast('Appointment updated');
            },
          ),
        );
        break;
      default:
        _showToast('Edit action not available for this card type.');
    }
  }

  Future<void> _showDeleteConfirmationDialog(String title, dynamic item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  _initializeCards();
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
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _columnLeft.length,
            itemBuilder: (context, index) {
              final cardData = _columnLeft[index];
              return _buildModelCard(cardData, context, index, key: ValueKey(cardData['id']!));
            },
            onReorder: (oldIndex, newIndex) => _onReorder(_columnLeft, oldIndex, newIndex),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _columnRight.length,
            itemBuilder: (context, index) {
              final cardData = _columnRight[index];
              return _buildModelCard(cardData, context, index, key: ValueKey(cardData['id']!));
            },
            onReorder: (oldIndex, newIndex) => _onReorder(_columnRight, oldIndex, newIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(Map<String, dynamic> cardData, BuildContext context, int index,
      {Key? key, bool isInModal = false}) {
    final String title = cardData['title']!;
    final dynamic data = cardData['data']!;
    final List<DataColumn> columns = cardData['columns']!;

    return Card(
      key: key,
      margin: isInModal ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // This makes the card's height intrinsic
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
                    onPressed: () => _showDetailView(cardData),
                  ),
                if (!isInModal)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
              ],
            ),
          ),
          DataTable(
            columns: columns,
            rows: _getRows(data, title),
          ),
        ],
      ),
    );
  }

  List<DataRow> _getRows(dynamic data, String title) {
    switch (title) {
      case 'Users':
        final user = data as User;
        return [
          DataRow(cells: [
            DataCell(Text(user.person.fullName)),
            DataCell(Text(user.person.dateOfBirth.toIso8601String().substring(0, 10))),
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openEditDialog(title, user.person),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: null, // Deleting user is not allowed
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showViewDialog(title, user.person),
                  ),
                ],
              ),
            ),
          ])
        ];
      case 'People':
        final people = data as List<Person>;
        return people.map((person) {
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
      case 'Calendar':
      case 'Tasks': // Tasks use the same data structure as Appointments for now
        final appointments = data as List<Appointment>;
        return appointments.map((appointment) {
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
      case 'Notes':
        final notes = data as List<Person>; // Using Person as dummy data model
        return notes.map((note) {
          return DataRow(cells: [
            DataCell(Text(note.fullName)), // Re-using fullName as the note content
            DataCell(Text(note.dateOfBirth.toIso8601String().substring(0, 10))), // Re-using dateOfBirth as created date
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showToast('Edit not available for notes'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(title, note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showViewDialog(title, note),
                  ),
                ],
              ),
            ),
          ]);
        }).toList();
      default:
        return [];
    }
  }
}