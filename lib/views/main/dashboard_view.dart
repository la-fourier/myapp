import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/widgets/data_card.dart';

class DashboardView extends StatefulWidget {
  final Function(Widget Function(ScrollController)) showAsModalSheet;
  const DashboardView({super.key, required this.showAsModalSheet});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final List<Map<String, dynamic>> _columnLeft = [];
  final List<Map<String, dynamic>> _columnRight = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCards();
  }

  void _initializeCards() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.loggedInUser;
    if (user == null) return;

    if (_columnLeft.isNotEmpty || _columnRight.isNotEmpty) return;

    final allCards = [
      {
        'id': 'users',
        'title': 'Users',
        'data': user,
      },
      {
        'id': 'people',
        'title': 'People',
        'data': user.contacts,
      },
      {
        'id': 'calendar',
        'title': 'Calendar',
        'data': user.calendar.appointments,
      },
      {
        'id': 'tasks',
        'title': 'Tasks',
        'data': [Appointment(title: 'Buy groceries', start: DateTime.now(), end: DateTime.now())],
      },
      {
        'id': 'notes',
        'title': 'Notes',
        'data': [Person(fullName: 'Remember to call mom', dateOfBirth: DateTime.now())], // Using Person as dummy data
      },
    ];

    setState(() {
      for (int i = 0; i < allCards.length; i++) {
        if (i.isEven) {
          _columnLeft.add(allCards[i]);
        } else {
          _columnRight.add(allCards[i]);
        }
      }
    });
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.loggedInUser == null) {
      return const Center(child: Text('No user logged in.'));
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

    return Card(
      key: key,
      margin: isInModal ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showToast('Add not implemented in this view yet.'),
                ),
                if (!isInModal)
                  IconButton(
                    icon: const Icon(Icons.open_in_full),
                    onPressed: () => _showDetailView(cardData),
                  ),
              ],
            ),
          ),
          _buildConfiguredDataCard(cardData),
        ],
      ),
    );
  }

  Widget _buildConfiguredDataCard(Map<String, dynamic> cardData) {
    final String id = cardData['id']!;
    final String title = cardData['title']!;
    final dynamic data = cardData['data']!;

    switch (id) {
      case 'users':
        final user = data as User;
        return DataCard<Person>(
          title: title,
          data: [user.person], // DataCard expects a List
          columns: [
            SortableColumn(
              label: 'Name',
              getField: (person) => person.fullName,
              cellBuilder: (person) => Text(person.fullName),
            ),
            SortableColumn(
              label: 'Date of Birth',
              getField: (person) => person.dateOfBirth,
              cellBuilder: (person) => Text(person.dateOfBirth.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: '',
              getField: (person) => '', // Not sortable
              cellBuilder: (person) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete), onPressed: null),
                  IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
                ],
              ),
            ),
          ],
        );
      case 'people':
        final people = data as List<Person>;
        return DataCard<Person>(
          title: title,
          data: people,
          columns: [
            SortableColumn(
              label: 'Name',
              getField: (person) => person.fullName,
              cellBuilder: (person) => Text(person.fullName),
            ),
            SortableColumn(
              label: 'Date of Birth',
              getField: (person) => person.dateOfBirth,
              cellBuilder: (person) => Text(person.dateOfBirth.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: '',
              getField: (person) => '', // Not sortable
              cellBuilder: (person) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
                ],
              ),
            ),
          ],
        );
      case 'calendar':
      case 'tasks':
        final appointments = data as List<Appointment>;
        return DataCard<Appointment>(
          title: title,
          data: appointments,
          columns: [
            SortableColumn(
              label: 'Title',
              getField: (appointment) => appointment.title,
              cellBuilder: (appointment) => Text(appointment.title),
            ),
            SortableColumn(
              label: 'Date',
              getField: (appointment) => appointment.start,
              cellBuilder: (appointment) => Text(appointment.start.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: '',
              getField: (appointment) => '', // Not sortable
              cellBuilder: (appointment) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
                ],
              ),
            ),
          ],
        );
      case 'notes':
        final notes = data as List<Person>; // Dummy data
        return DataCard<Person>(
          title: title,
          data: notes,
          columns: [
            SortableColumn(
              label: 'Note',
              getField: (note) => note.fullName,
              cellBuilder: (note) => Text(note.fullName),
            ),
            SortableColumn(
              label: 'Created',
              getField: (note) => note.dateOfBirth,
              cellBuilder: (note) => Text(note.dateOfBirth.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: '',
              getField: (note) => '', // Not sortable
              cellBuilder: (note) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
