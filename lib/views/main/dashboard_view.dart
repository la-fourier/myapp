import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';
import 'package:myapp/widgets/data_card.dart';
import 'package:myapp/dialogs/category_editor_dialog.dart';
import 'package:myapp/dialogs/person_editor_dialog.dart';
import 'package:myapp/dialogs/appointment_editor_dialog.dart';

class DashboardView extends StatefulWidget {
  final Function(Widget Function(ScrollController)) showAsModalSheet;
  const DashboardView({super.key, required this.showAsModalSheet});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String _selectedDataSourceId = 'people';
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      setState(() {}); // Re-render to apply filter
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _showCategoryEditor({Category? category}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => CategoryEditorDialog(category: category),
    );

    if (result != null) {
      if (category == null) {
        appState.addCustomCategory(result);
      } else {
        appState.updateCustomCategory(category, result);
      }
    }
  }

  void _showPersonEditor({Person? person}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => PersonEditorDialog(
        person: person,
        onSave: (newPerson) {
          if (person == null) {
            appState.addPerson(newPerson);
          } else {
            // Person model needs to implement == for this to work correctly
            appState.loggedInUser!.updatePerson(newPerson);
          }
        },
      ),
    );
  }

  void _showAppointmentEditor({Appointment? appointment}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AppointmentEditorDialog(
        appointment: appointment,
        onSave: (newAppointment) {
          if (appointment == null) {
            appState.addAppointment(newAppointment);
          } else {
            appState.updateAppointment(appointment, newAppointment);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.loggedInUser;
    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    final Map<String, Map<String, dynamic>> dataSources = {
      'people': {
        'title': 'People',
        'data': user.contacts,
        'add_new': () => _showPersonEditor(),
      },
      'calendar': {
        'title': 'Appointments',
        'data': user.calendar.appointments,
        'add_new': () => _showAppointmentEditor(),
      },
      'categories': {
        'title': 'Categories',
        'data': user.customCategories,
        'add_new': () => _showCategoryEditor(),
      },
      'tracked_activities': {
        'title': 'Tracked Activities',
        'data': user.calendar.trackedActivities,
        'add_new': null,
      },
    };

    final selectedSource = dataSources[_selectedDataSourceId]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _selectedDataSourceId,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDataSourceId = newValue;
                    });
                  }
                },
                items: dataSources.keys.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(dataSources[value]!['title']! as String),
                  );
                }).toList(),
              ),
              if (selectedSource['add_new'] != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add New',
                  onPressed: selectedSource['add_new'] as void Function(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _filterController,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: _buildConfiguredDataCard(
                appState,
                _selectedDataSourceId,
                selectedSource['data']!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguredDataCard(AppState appState, String id, dynamic data) {
    return _buildDataCardForId(id, appState, data);
  }

  Widget _buildDataCardForId(String id, AppState appState, dynamic data) {
    switch (id) {
      case 'people':
        return DataCard<Person>(
          filterText: _filterController.text,
          data: data as List<Person>,
          columns: [
            SortableColumn(
              label: 'Name',
              getField: (item) => item.fullName,
              cellBuilder: (item) => Text(item.fullName),
            ),
            SortableColumn(
              label: 'Date of Birth',
              getField: (item) => item.dateOfBirth,
              cellBuilder: (item) =>
                  Text(item.dateOfBirth.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: 'Actions',
              getField: (item) => '',
              cellBuilder: (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showPersonEditor(person: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => appState.loggedInUser!.deleteContact(item),
                  ),
                ],
              ),
            ),
          ],
        );
      case 'calendar':
        return DataCard<Appointment>(
          filterText: _filterController.text,
          data: data as List<Appointment>,
          columns: [
            SortableColumn(
              label: 'Title',
              getField: (item) => item.title,
              cellBuilder: (item) => Text(item.title),
            ),
            SortableColumn(
              label: 'Start Date',
              getField: (item) => item.start,
              cellBuilder: (item) =>
                  Text(item.start.toIso8601String().substring(0, 10)),
            ),
            SortableColumn(
              label: 'Actions',
              getField: (item) => '',
              cellBuilder: (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showAppointmentEditor(appointment: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => appState.deleteAppointment(item),
                  ),
                ],
              ),
            ),
          ],
        );
      case 'categories':
        return DataCard<Category>(
          filterText: _filterController.text,
          data: data as List<Category>,
          columns: [
            SortableColumn(
              label: 'Color',
              getField: (item) => item.color.value.toString(),
              cellBuilder: (item) => Icon(Icons.circle, color: item.color),
            ),
            SortableColumn(
              label: 'Name',
              getField: (item) => item.name,
              cellBuilder: (item) => Text(item.name),
            ),
            SortableColumn(
              label: 'Actions',
              getField: (item) => '',
              cellBuilder: (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showCategoryEditor(category: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => appState.deleteCustomCategory(item),
                  ),
                ],
              ),
            ),
          ],
        );
      case 'tracked_activities':
        return DataCard<TrackedActivity>(
          filterText: _filterController.text,
          data: data as List<TrackedActivity>,
          columns: [
            SortableColumn(
              label: 'Name',
              getField: (item) => item.name,
              cellBuilder: (item) => Text(item.name),
            ),
            SortableColumn(
              label: 'Category',
              getField: (item) => item.category.name,
              cellBuilder: (item) => Text(item.category.name),
            ),
            SortableColumn(
              label: 'Start Time',
              getField: (item) => item.startTime,
              cellBuilder: (item) =>
                  Text(item.startTime.toIso8601String().substring(11, 16)),
            ),
            SortableColumn(
              label: 'End Time',
              getField: (item) => item.endTime,
              cellBuilder: (item) =>
                  Text(item.endTime.toIso8601String().substring(11, 16)),
            ),
            SortableColumn(
              label: 'Duration (Mins)',
              getField: (item) =>
                  item.endTime.difference(item.startTime).inMinutes,
              cellBuilder: (item) => Text(
                item.endTime.difference(item.startTime).inMinutes.toString(),
              ),
            ),
          ],
        );
      default:
        return const Center(child: Text("No data view available."));
    }
  }
}
