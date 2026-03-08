import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HabitsView extends StatelessWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final habits = appState.loggedInUser?.habits ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showHabitEditor(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: habits.isEmpty
              ? const Center(child: Text('No habits yet.'))
              : ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return ListTile(
                      leading: Icon(Icons.circle, color: appState.loggedInUser?.customCategories.firstWhereOrNull((c) => c.name == habit.categoryId)?.color ?? Colors.grey),
                      title: Text(habit.name),
                      subtitle: Text(habit.frequencyLabel),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('P${habit.priority}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showHabitEditor(context, habit: habit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => appState.deleteItem<Habit>(habit),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showHabitEditor(BuildContext context, {Habit? habit}) {
    showDialog(
      context: context,
      builder: (context) => HabitEditorDialog(habit: habit),
    );
  }
}

class HabitEditorDialog extends StatefulWidget {
  final Habit? habit;

  const HabitEditorDialog({super.key, this.habit});

  @override
  State<HabitEditorDialog> createState() => _HabitEditorDialogState();
}

class _HabitEditorDialogState extends State<HabitEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late int _frequencyTimes;
  late FrequencyPeriod _frequencyPeriod;
  TimeOfDay? _preferredStart;
  TimeOfDay? _preferredEnd;
  late int _priority;
  late int _froggyness;
  late Set<String> _contactUids;
  late Duration _minLength;
  late Duration _maxLength;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name);
    _addressController = TextEditingController(text: widget.habit?.address);
    _frequencyTimes = widget.habit?.frequencyTimes ?? 3;
    _frequencyPeriod = widget.habit?.frequencyPeriod ?? FrequencyPeriod.week;
    _preferredStart = widget.habit?.preferredStartTime;
    _preferredEnd = widget.habit?.preferredEndTime;
    _priority = widget.habit?.priority ?? 3;
    _froggyness = widget.habit?.froggyness ?? 0;
    _contactUids = Set<String>.from(widget.habit?.contactUids ?? []);
    _minLength = widget.habit?.minLength ?? const Duration(minutes: 5);
    _maxLength = widget.habit?.maxLength ?? const Duration(minutes: 60);
    _categoryId = widget.habit?.categoryId;
  }

  String _formatTime(TimeOfDay? t) => t != null ? '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : 'Any';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Provider.of<AppState>(context).loggedInUser?.customCategories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList() ?? [],
                onChanged: (cat) => setState(() => _categoryId = cat),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const SizedBox(height: 16),
              // Frequency
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _frequencyTimes,
                      decoration: const InputDecoration(labelText: 'Times'),
                      items: List.generate(10, (i) => i + 1)
                          .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                          .toList(),
                      onChanged: (val) => setState(() => _frequencyTimes = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('per'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<FrequencyPeriod>(
                      value: _frequencyPeriod,
                      decoration: const InputDecoration(labelText: 'Period'),
                      items: FrequencyPeriod.values
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                          .toList(),
                      onChanged: (val) => setState(() => _frequencyPeriod = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preferred time window
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text('From: ${_formatTime(_preferredStart)}'),
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: _preferredStart ?? const TimeOfDay(hour: 8, minute: 0));
                        if (t != null) setState(() => _preferredStart = t);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text('To: ${_formatTime(_preferredEnd)}'),
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: _preferredEnd ?? const TimeOfDay(hour: 20, minute: 0));
                        if (t != null) setState(() => _preferredEnd = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minLength.inMinutes.toString(),
                      decoration: const InputDecoration(labelText: 'Min Length (min)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _minLength = Duration(minutes: int.tryParse(v) ?? 5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxLength.inMinutes.toString(),
                      decoration: const InputDecoration(labelText: 'Max Length (min)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _maxLength = Duration(minutes: int.tryParse(v) ?? 60),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Priority (0-5)'),
              Slider(
                value: _priority.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _priority.toString(),
                onChanged: (val) => setState(() => _priority = val.round()),
              ),
              const Text('Froggyness (0-5)'),
              Slider(
                value: _froggyness.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _froggyness.toString(),
                onChanged: (val) => setState(() => _froggyness = val.round()),
              ),
              const Divider(),
              ExpansionTile(
                title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                children: Provider.of<AppState>(context).loggedInUser!.contacts.map((contact) {
                  final isSelected = _contactUids.contains(contact.uid);
                  return CheckboxListTile(
                    title: Text(contact.fullName),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _contactUids.add(contact.uid);
                        } else {
                          _contactUids.remove(contact.uid);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final appState = Provider.of<AppState>(context, listen: false);
              final newHabit = Habit(
                id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                frequencyTimes: _frequencyTimes,
                frequencyPeriod: _frequencyPeriod,
                preferredStartTime: _preferredStart,
                preferredEndTime: _preferredEnd,
                priority: _priority,
                froggyness: _froggyness,
                minLength: _minLength,
                maxLength: _maxLength,
                contactUids: _contactUids.toList(),
                categoryId: _categoryId,
                address: _addressController.text.isEmpty ? null : _addressController.text,
              );

              if (widget.habit == null) {
                appState.addItem<Habit>(newHabit);
              } else {
                appState.updateItem<Habit>(widget.habit!, newHabit);
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
