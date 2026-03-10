import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/views/habits/habits_view.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import '../../models/person.dart';
import '../../services/app_state.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:flutter/services.dart';


class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final contacts = appState.loggedInUser?.contacts ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Plan Appointment with...'),
                onPressed: () {
                  final contacts =
                      Provider.of<AppState>(context, listen: false).loggedInUser?.contacts ?? [];
                  if (contacts.isNotEmpty) {
                    _showContactSelectionDialog(context, contacts);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add a contact before planning an appointment.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showContactEditor(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: !appState.isInitialized
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 8,
                  itemBuilder: (context, index) => const SkeletonListTile(),
                )
              : contacts.isEmpty
                  ? EmptyStateWidget(
                      title: 'No contacts yet',
                      message: 'Keep track of the people in your life.',
                      icon: Icons.people_outline,
                      actionLabel: 'Add Contact',
                      onAction: () => _showContactEditor(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                contact.fullName.isNotEmpty ? contact.fullName[0].toUpperCase() : '?',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                              ),
                            ),
                            title: Text(contact.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(contact.email ?? contact.phoneNumber ?? 'No contact info'),
                            onTap: () => _showContactEditor(context, contact: contact),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                appState.deleteItem<Person>(contact);
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showContactSelectionDialog(BuildContext context, List<Person> contacts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Contact'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.fullName),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the selection dialog
                    _generateAndShowLink(context, contact);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _generateAndShowLink(BuildContext context, Person contact) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.loggedInUser;
    if (user == null) return;

    final credibility = contact.credibility?.name ?? 'unknown';
    final host = Uri.base.host;
    final port = Uri.base.port;

    // Encode user data
    final data = {
      'appointments': user.calendar.appointments.map((a) => a.toJson()).toList(),
      'credibility': credibility,
      'contactUid': contact.uid,
    };
    final encodedData = base64Encode(utf8.encode(jsonEncode(data)));
    final link = 'http://$host:$port/#/shared/$encodedData';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shareable Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share this link with ${contact.fullName} to coordinate an appointment:'),
              const SizedBox(height: 16),
              SelectableText(
                link,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showContactEditor(BuildContext context, {Person? contact}) {
    showDialog(
      context: context,
      builder: (context) => ContactEditorDialog(contact: contact),
    );
  }
}

class ContactEditorDialog extends StatefulWidget {
  final Person? contact;

  const ContactEditorDialog({super.key, this.contact});

  @override
  State<ContactEditorDialog> createState() => _ContactEditorDialogState();
}

class _ContactEditorDialogState extends State<ContactEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.fullName);
    _emailController = TextEditingController(text: widget.contact?.email);
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber);
    _addressController = TextEditingController(text: widget.contact?.address);
    _latController = TextEditingController(text: widget.contact?.location?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.contact?.location?.longitude.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final appState = Provider.of<AppState>(context, listen: false);
              final newContact = Person(
                uid: widget.contact?.uid ?? DateTime.now().millisecondsSinceEpoch.toString(),
                fullName: _nameController.text,
                dateOfBirth: widget.contact?.dateOfBirth ?? DateTime(1990, 1, 1),
                email: _emailController.text.isEmpty ? null : _emailController.text,
                phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                location: (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                    ? LatLng(double.parse(_latController.text), double.parse(_lngController.text))
                    : null,
              );

              if (widget.contact == null) {
                appState.addItem<Person>(newContact);
              } else {
                appState.updateItem<Person>(widget.contact!, newContact);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
