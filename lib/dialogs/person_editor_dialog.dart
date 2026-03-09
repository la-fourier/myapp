import 'dart:convert';
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
  String? _email;
  String? _phoneNumber;

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.person != null) {
      _fullName = widget.person!.fullName;
      _dateOfBirth = widget.person!.dateOfBirth;
      _email = widget.person!.email;
      _phoneNumber = widget.person!.phoneNumber;
    } else {
      _fullName = '';
      _dateOfBirth = DateTime.now();
    }
    _rawTextController.text = _personToJson();
  }

  String _personToJson() {
    final data = {
      'uid': widget.person?.uid ?? 'new_${DateTime.now().millisecondsSinceEpoch}',
      'fullName': _fullName,
      'dateOfBirth': _dateOfBirth.toIso8601String(),
      'email': _email,
      'phoneNumber': _phoneNumber,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _jsonToPerson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      setState(() {
        _fullName = data['fullName'];
        _dateOfBirth = DateTime.parse(data['dateOfBirth']);
        _email = data['email'];
        _phoneNumber = data['phoneNumber'];
      });
    } catch (e) {
      // Handle JSON parsing error
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
    if (_isRawEditMode) {
      _jsonToPerson(_rawTextController.text);
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPerson = Person(
        uid: widget.person?.uid ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullName,
        dateOfBirth: _dateOfBirth,
        email: _email,
        phoneNumber: _phoneNumber,
      );

      widget.onSave(newPerson);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.person == null ? 'Add Person' : 'Edit Person'),
          IconButton(
            icon: Icon(_isRawEditMode ? Icons.notes : Icons.code),
            onPressed: () {
              setState(() {
                _isRawEditMode = !_isRawEditMode;
                if (_isRawEditMode) {
                  _rawTextController.text = _personToJson();
                } else {
                  _jsonToPerson(_rawTextController.text);
                }
              });
            },
          ),
        ],
      ),
      content: _isRawEditMode
          ? TextField(
              controller: _rawTextController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Raw Text (JSON)',
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: _fullName,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      onChanged: (value) => _fullName = value,
                      validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Birthday'),
                              child: Text(DateFormat.yMd().format(_dateOfBirth)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _email = value,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _phoneNumber,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => _phoneNumber = value,
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
