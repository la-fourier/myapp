import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/category.dart';

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

  final List<Category> _categories = [
    Category(name: 'Work', color: Colors.blue),
    Category(name: 'Personal', color: Colors.green),
    Category(name: 'Urgent', color: Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _title = widget.appointment!.title;
      _description = widget.appointment!.description ?? '';
      _startDate = widget.appointment!.start;
      _endDate = widget.appointment!.end;
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _category = widget.appointment!.category;
    } else {
      _title = '';
      _description = '';
      _startDate = widget.startTime ?? DateTime.now();
      _endDate = (widget.startTime ?? DateTime.now()).add(const Duration(hours: 1));
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _category = _categories.first;
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
      );

      widget.onSave(newAppointment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.appointment == null ? 'Create Appointment' : 'Edit Appointment'),
      content: Form(
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
                    child: Text('Start: ${DateFormat.yMd().format(_startDate)}'),
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
                    child: Text('Start Time: ${_startTime.format(context)}'),
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
                    child: Text('End: ${DateFormat.yMd().format(_endDate)}'),
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
                    child: Text('End Time: ${_endTime.format(context)}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, false),
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
