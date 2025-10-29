import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/appointment.dart';

class DashboardView extends StatefulWidget {
  final Function(Widget Function(ScrollController)) showAsModalSheet;
  const DashboardView({super.key, required this.showAsModalSheet});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final List<Map<String, dynamic>> _columnLeft = [];
  final List<Map<String, dynamic>> _columnRight = [];

  // Using didChangeDependencies to initialize data from Provider
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCards();
  }

  void _initializeCards() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.loggedInUser;
    if (user == null) return;

    // Initialize only if the columns are empty to avoid re-shuffling on every build
    if (_columnLeft.isNotEmpty || _columnRight.isNotEmpty) return;

    final allCards = [
      {
        'id': 'users',
        'title': 'Users',
        'data': user,
        'columns': [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Date of Birth')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'people',
        'title': 'People',
        'data': user.contacts,
        'columns': [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Date of Birth')),
          const DataColumn(label: Text('')),
        ],
      },
      {
        'id': 'calendar',
        'title': 'Calendar',
        'data': user.calendar.appointments,
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

  // Dialog and other helper methods remain the same, but will now use AppState for modifications
  // ...

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
    final dynamic data = cardData['data']!;
    final List<DataColumn> columns = cardData['columns']!;

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
    // This logic is now simplified as it depends on the AppState to be the source of truth
    // and modifications will be handled by AppState methods (not implemented here yet)
    switch (title) {
      case 'Users':
        final user = data as User;
        return [DataRow(cells: [DataCell(Text(user.person.fullName)), DataCell(Text(user.person.dateOfBirth.toIso8601String().substring(0, 10))), DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () {}), IconButton(icon: const Icon(Icons.delete), onPressed: null), IconButton(icon: const Icon(Icons.visibility), onPressed: () {})]))])];
      case 'People':
        final people = data as List<Person>;
        return people.map((person) => DataRow(cells: [DataCell(Text(person.fullName)), DataCell(Text(person.dateOfBirth.toIso8601String().substring(0, 10))), DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () {}), IconButton(icon: const Icon(Icons.delete), onPressed: () {}), IconButton(icon: const Icon(Icons.visibility), onPressed: () {})]))])).toList();
      case 'Calendar':
      case 'Tasks':
        final appointments = data as List<Appointment>;
        return appointments.map((appointment) => DataRow(cells: [DataCell(Text(appointment.title)), DataCell(Text(appointment.start.toIso8601String().substring(0, 10))), DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () {}), IconButton(icon: const Icon(Icons.delete), onPressed: () {}), IconButton(icon: const Icon(Icons.visibility), onPressed: () {})]))])).toList();
      case 'Notes':
        final notes = data as List<Person>;
        return notes.map((note) => DataRow(cells: [DataCell(Text(note.fullName)), DataCell(Text(note.dateOfBirth.toIso8601String().substring(0, 10))), DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () {}), IconButton(icon: const Icon(Icons.delete), onPressed: () {}), IconButton(icon: const Icon(Icons.visibility), onPressed: () {})]))])).toList();
      default:
        return [];
    }
  }
}
