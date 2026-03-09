import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/app_state.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/finance/attachment.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/dialogs/bill_editor_dialog.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

class AppointmentEditorDialog extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;
  final DateTime? startTime;

  const AppointmentEditorDialog({
    super.key,
    this.appointment,
    required this.onSave,
    this.startTime,
  });

  @override
  State<AppointmentEditorDialog> createState() =>
      _AppointmentEditorDialogState();
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
  late Priority _priority;
  late Set<String> _contactUids;
  String _address = '';
  double? _lat;
  double? _lng;

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _categories = List<Category>.from(appState.loggedInUser?.customCategories ?? []);

    if (widget.appointment != null) {
      _title = widget.appointment!.title;
      _description = widget.appointment!.description ?? '';
      _startDate = widget.appointment!.start;
      _endDate = widget.appointment!.end;
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _category = widget.appointment!.category;
      _attachments = List.from(widget.appointment!.attachments);
      _priority = widget.appointment!.priority;
      _contactUids = Set<String>.from(widget.appointment!.contactUids);
      _address = widget.appointment!.address ?? '';
      _lat = widget.appointment!.location?.latitude;
      _lng = widget.appointment!.location?.longitude;

      if (!_categories.contains(_category)) {
        _categories.insert(0, _category);
      }
    } else {
      _title = '';
      _description = '';
      _startDate = widget.startTime ?? DateTime.now();
      _endDate = (widget.startTime ?? DateTime.now()).add(
        const Duration(hours: 1),
      );
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      if (_categories.isEmpty) {
        _categories.add(Category(name: 'Default', color: Colors.blue));
      }
      _category = _categories.first;
      _attachments = [];
      _priority = Priority.normal;
      _contactUids = {};
    }
    _rawTextController.text = _appointmentToJson();
  }

  String _appointmentToJson() {
    final data = {
      'title': _title,
      'description': _description,
      'start': DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      ).toIso8601String(),
      'end': DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      ).toIso8601String(),
      'category': _category.toJson(),
      'priority': _priority.toString(),
      'contactUids': _contactUids.toList(),
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
        _priority = Priority.values.firstWhere(
          (e) => e.toString() == data['priority'],
          orElse: () => Priority.normal,
        );
        _contactUids = Set<String>.from(data['contactUids'] ?? []);
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
        priority: _priority,
        contactUids: _contactUids.toList(),
        address: _address.isEmpty ? null : _address,
        location: (_lat != null && _lng != null) ? LatLng(_lat!, _lng!) : null,
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
          Text(
            widget.appointment == null
                ? 'Create Appointment'
                : 'Edit Appointment',
          ),
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
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                      onSaved: (value) => _title = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _lat?.toString(),
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onSaved: (value) => _lat = double.tryParse(value ?? ''),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _lng?.toString(),
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onSaved: (value) => _lng = double.tryParse(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Table(
                      children: [
                    TableRow(
                      children: [
                        Row(children: [
                              Text("Start:"),
                              SizedBox(width: 10),
                              Expanded(
                                child: editable_text.EditableText(
                                  initialText:
                                      DateFormat.yMd().format(_startDate),
                                  style: Theme.of(context).textTheme.bodyLarge!,
                                  onSave: (value) {
                                    try {
                                      final newDate = DateFormat.yMd().parse(
                                        value,
                                      );
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
                                enableFeedback: true,
                                hoverColor: Colors.transparent,
                                iconSize: 16,
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context, true),
                              ),
                              Expanded(
                                child: editable_text.EditableText(
                                  initialText:
                                      _startTime.format(context),
                                  style: Theme.of(context).textTheme.bodyLarge!,
                                  onSave: (value) {
                                    try {
                                      final newTime = TimeOfDay(
                                        hour: int.parse(
                                          value
                                              .split(':')[0],
                                        ),
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
                                enableFeedback: true,
                                hoverColor: Colors.transparent,
                                iconSize: 16,
                                icon: const Icon(Icons.access_time),
                                onPressed: () => _selectTime(context, true),
                              ),
                            ],
                          ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Container(width: 400),
                        // const SizedBox(height: 1),
                        // const SizedBox(width: 80),
                        // const SizedBox(height: 1),
                        // const SizedBox(width: 80),
                        // const SizedBox(height: 1),
                      ],
                    ),
                    TableRow(
                      children: [
                        Row(
                          children: [
                        Text("End:"),
                        SizedBox(width: 10),
                        Expanded(
                          child: editable_text.EditableText(
                            initialText:
                                DateFormat.yMd().format(_endDate),
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newDate = DateFormat.yMd().parse(
                                  value,
                                );
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
                          enableFeedback: true,
                          hoverColor: Colors.transparent,
                          iconSize: 16,
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context, false),
                        ),
                        Expanded(
                          child: editable_text.EditableText(
                            initialText:
                            _endTime.format(context),
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newTime = TimeOfDay(
                                  hour: int.parse(
                                    value
                                        .split(':')[0],
                                  ),
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
                          enableFeedback: true,
                          hoverColor: Colors.transparent,
                          iconSize: 16,
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context, false),
                        ),
                      ],
                    ),
                      ],
                    ),
                      ],
                    ),
                    const Divider(height: 20),
                    ExpansionTile(
                      title: const Text('Advanced Settings'),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                      expansionAnimationStyle: AnimationStyle(curve: Curves.easeInOut),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      children: [
                        SizedBox(width: 10),
                        if (_categories.isNotEmpty)
                          DropdownButtonFormField<Category>(
                            initialValue: _category,
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
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                          SizedBox(height: 10),
                        DropdownButtonFormField<Priority>(
                          initialValue: _priority,
                          items: Priority.values.map((Priority priority) {
                            return DropdownMenuItem<Priority>(
                              value: priority,
                              child: Text(priority.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (Priority? newValue) {
                            setState(() {
                              _priority = newValue!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Text(
                             //   textAlign: TextAlign.center,
                             //   'Attachments',
                             //   style: Theme.of(context).textTheme.titleMedium,
                             // ),
                             ..._attachments.map(
                               (attachment) => ListTile(
                                 leading: const Icon(Icons.receipt),
                                 title: Text(attachment.name),
                                 subtitle: Text(attachment.type),
                                 trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _attachments.remove(attachment);
                                    });
                                  },
                                ),
                               ),
                             ),
                             const SizedBox(height: 12),
                             Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Expanded(
                                   child: DropdownButtonFormField<Attachment>(
                                     decoration: const InputDecoration(
                                       labelText: 'Add Existing File',
                                       border: OutlineInputBorder(),
                                       prefixIcon: Icon(Icons.search),
                                     ),
                                     items: [
                                        const DropdownMenuItem<Attachment>(
                                          value: null,
                                          child: Text('Select a file to attach...'),
                                        ),
                                        ...Provider.of<AppState>(context, listen: false)
                                           .loggedInUser?.bills.map((bill) {
                                             return DropdownMenuItem<Attachment>(
                                               value: bill,
                                               child: Text('${bill.name} (${bill.type})'),
                                             );
                                           }) ?? []
                                     ],
                                     onChanged: (Attachment? selectedObj) {
                                       if (selectedObj != null && !_attachments.any((a) => a.name == selectedObj.name)) {
                                           setState(() {
                                             _attachments.add(selectedObj);
                                           });
                                       }
                                     },
                                     value: null,
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 Tooltip(
                                   message: 'Create New File',
                                   child: FilledButton.icon(
                                     style: FilledButton.styleFrom(
                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                     ),
                                     icon: const Icon(Icons.add),
                                     label: const Text('New'),
                                     onPressed: () {
                                       showDialog(
                                         context: context,
                                         builder: (context) => BillEditorDialog(
                                           onSave: (bill) {
                                             setState(() {
                                               _attachments.add(bill);
                                             });
                                             // Also add the bill to the user's main list of bills
                                             Provider.of<AppState>(
                                               context,
                                               listen: false,
                                             ).loggedInUser?.bills.add(bill);
                                           },
                                         ),
                                       );
                                     },
                                   ),
                                 ),
                               ],
                             ),
                           ],
                        ),
                        const Divider(),
                        const Text('Link Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...Provider.of<AppState>(context).loggedInUser!.contacts.map((contact) {
                          return CheckboxListTile(
                            title: Text(contact.fullName),
                            value: _contactUids.contains(contact.uid),
                            onChanged: (v) => setState(() => v! ? _contactUids.add(contact.uid) : _contactUids.remove(contact.uid)),
                          );
                        }),
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
