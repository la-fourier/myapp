import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

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

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

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
    _rawTextController.text = _personToJson();
  }

  String _personToJson() {
    final data = {
      'fullName': _fullName,
      'dateOfBirth': _dateOfBirth.toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _jsonToPerson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      setState(() {
        _fullName = data['fullName'];
        _dateOfBirth = DateTime.parse(data['dateOfBirth']);
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

      final newPerson = Person(fullName: _fullName, dateOfBirth: _dateOfBirth);

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
                    editable_text.EditableText(
                      initialText: _fullName,
                      style: Theme.of(context).textTheme.titleLarge!,
                      onSave: (value) {
                        setState(() {
                          _fullName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: DateFormat.yMd().format(_dateOfBirth),
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newDate = DateFormat.yMd().parse(value);
                                setState(() {
                                  _dateOfBirth = newDate;
                                });
                              } catch (e) {
                                // Handle parsing error
                              }
                            },
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
        ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
      ],
    );
  }
}
