import 'package:flutter/material.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

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
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showContactEditor(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: contacts.isEmpty
              ? const Center(child: Text('No contacts yet.'))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(contact.fullName[0].toUpperCase()),
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(contact.email ?? contact.phoneNumber ?? 'No contact info'),
                      onTap: () => _showContactEditor(context, contact: contact),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          appState.deleteItem<Person>(contact);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.fullName);
    _emailController = TextEditingController(text: widget.contact?.email);
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber);
    _addressController = TextEditingController(text: widget.contact?.address);
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
