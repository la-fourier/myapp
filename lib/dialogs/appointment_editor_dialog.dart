import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/attachment.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

class AppointmentEditorDialog extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;
  final DateTime? startTime;

  const AppointmentEditorDialog({super.key, this.appointment, required this.onSave, this.startTime});

  @override
  State<AppointmentEditorDialog> createState() => _AppointmentEditorDialogState();
}

class _AppointmentEditorDialogState extends State<AppointmentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Category _category;
  late List<Category> _categories;
  late List<Attachment> _attachments;

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _categories = appState.loggedInUser?.customCategories ?? [];

    if (widget.appointment != null) {
      _title = widget.appointment!.title;
      _description = widget.appointment!.description ?? '';
      _startDate = widget.appointment!.start;
      _endDate = widget.appointment!.end;
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _category = widget.appointment!.category;
      _attachments = List.from(widget.appointment!.attachments);
    } else {
      _title = '';
      _description = '';
      _startDate = widget.startTime ?? DateTime.now();
      _endDate = (widget.startTime ?? DateTime.now()).add(const Duration(hours: 1));
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _category = _categories.isNotEmpty ? _categories.first : Category(name: 'Default', color: Colors.blue);
      _attachments = [];
    }
    _rawTextController.text = _appointmentToJson();
  }

  String _appointmentToJson() {
    final data = {
      'title': _title,
      'description': _description,
      'start': DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute).toIso8601String(),
      'end': DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute).toIso8601String(),
      'category': _category.toJson(),
      // Attachments are not handled in raw edit mode for now
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _jsonToAppointment(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      setState(() {
        _title = data['title'];
        _description = data['description'];
        _startDate = DateTime.parse(data['start']);
        _endDate = DateTime.parse(data['end']);
        _startTime = TimeOfDay.fromDateTime(_startDate);
        _endTime = TimeOfDay.fromDateTime(_endDate);
        _category = Category.fromJson(data['category']);
      });
    } catch (e) {
      // Handle JSON parsing error
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null && picked != (isStart ? _startTime : _endTime)) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (_isRawEditMode) {
      _jsonToAppointment(_rawTextController.text);
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final finalStartDate = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final finalEndDate = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final newAppointment = Appointment(
        title: _title,
        description: _description,
        start: finalStartDate,
        end: finalEndDate,
        category: _category,
        attachments: _attachments,
      );

      widget.onSave(newAppointment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.appointment == null ? 'Create Appointment' : 'Edit Appointment'),
          IconButton(
            icon: Icon(_isRawEditMode ? Icons.notes : Icons.code),
            onPressed: () {
              setState(() {
                _isRawEditMode = !_isRawEditMode;
                if (_isRawEditMode) {
                  _rawTextController.text = _appointmentToJson();
                } else {
                  _jsonToAppointment(_rawTextController.text);
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
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                      onSaved: (value) => _title = value!,
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(labelText: 'Description'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    if (_categories.isNotEmpty)
                      DropdownButtonFormField<Category>(
                        value: _category,
                        items: _categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (Category? newValue) {
                          setState(() {
                            _category = newValue!;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: 'Start: ${DateFormat.yMd().format(_startDate)}',
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newDate = DateFormat.yMd().parse(value.replaceFirst('Start: ', ''));
                                setState(() {
                                  _startDate = newDate;
                                });
                              } catch (e) {
                                // Handle parsing error
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, true),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: 'Start Time: ${_startTime.format(context)}',
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newTime = TimeOfDay(
                                  hour: int.parse(value.split(':')[0].replaceFirst('Start Time: ', '')),
                                  minute: int.parse(value.split(':')[1]),
                                );
                                setState(() {
                                  _startTime = newTime;
                                });
                              } catch (e) {
                                // Handle parsing error
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context, true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: 'End: ${DateFormat.yMd().format(_endDate)}',
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newDate = DateFormat.yMd().parse(value.replaceFirst('End: ', ''));
                                setState(() {
                                  _endDate = newDate;
                                });
                              } catch (e) {
                                // Handle parsing error
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: 'End Time: ${_endTime.format(context)}',
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newTime = TimeOfDay(
                                  hour: int.parse(value.split(':')[0].replaceFirst('End Time: ', '')),
                                  minute: int.parse(value.split(':')[1]),
                                );
                                setState(() {
                                  _endTime = newTime;
                                });
                              } catch (e) {
                                // Handle parsing error
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context, false),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                        ..._attachments.map((attachment) => ListTile(
                              leading: const Icon(Icons.receipt),
                              title: Text(attachment.name),
                              subtitle: Text(attachment.type),
                            )),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Attachment'),
                          onPressed: () {
                            // TODO: Implement attachment selection/creation
                          },
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
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
