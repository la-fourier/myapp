import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/models/calendar.dart';
import 'package:myapp/models/appointment.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a dummy user for demonstration purposes
    final user = User(
      person: Person(fullName: 'John Doe', dateOfBirth: DateTime(1990, 1, 1)),
      contacts: [
        Person(fullName: 'Jane Smith', dateOfBirth: DateTime(1992, 5, 10)),
        Person(fullName: 'Peter Jones', dateOfBirth: DateTime(1988, 11, 22)),
      ],
      calendar: Calendar(appointments: [
        Appointment(title: 'Meeting with team', date: DateTime.now(), contacts: []),
        Appointment(title: 'Lunch with Jane', date: DateTime.now().add(const Duration(days: 1)), contacts: []),
      ]),
    );

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildModelCard(context, 'Users', user, [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('DOB')),
        ]),
        _buildModelCard(context, 'People', user.contacts, [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('DOB')),
        ]),
        _buildModelCard(context, 'Calendar', user.calendar.appointments, [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Date')),
        ]),
      ],
    );
  }

  Widget _buildModelCard(BuildContext context, String title, dynamic data, List<DataColumn> columns) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Handle adding new data
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columns: columns,
              rows: _getRows(data),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _getRows(dynamic data) {
    if (data is User) {
      return [
        DataRow(cells: [
          DataCell(Text(data.person.fullName)),
          DataCell(Text(data.person.dateOfBirth.toIso8601String().substring(0, 10))),
        ])
      ];
    } else if (data is List<Person>) {
      return data.map((person) {
        return DataRow(cells: [
          DataCell(Text(person.fullName)),
          DataCell(Text(person.dateOfBirth.toIso8601String().substring(0, 10))),
        ]);
      }).toList();
    } else if (data is List<Appointment>) {
      return data.map((appointment) {
        return DataRow(cells: [
          DataCell(Text(appointment.title)),
          DataCell(Text(appointment.date.toIso8601String().substring(0, 10))),
        ]);
      }).toList();
    }
    return [];
  }
}
