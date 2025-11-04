import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/person.dart';

class PersonEditorDialog extends StatefulWidget {
  final Person? person;
  final Function(Person) onSave;

  const PersonEditorDialog({super.key, this.person, required this.onSave});

  @override
  State<PersonEditorDialog> createState() => _PersonEditorDialogState();
}

class _PersonEditorDialogState extends State<PersonEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _fullName;
  late DateTime _dateOfBirth;

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _fullName = widget.person!.fullName;
      _dateOfBirth = widget.person!.dateOfBirth;
    } else {
      _fullName = '';
      _dateOfBirth = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPerson = Person(fullName: _fullName, dateOfBirth: _dateOfBirth);

      widget.onSave(newPerson);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _fullName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _fullName = value!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date of Birth: ${DateFormat.yMd().format(_dateOfBirth)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
      ],
    );
  }
}
