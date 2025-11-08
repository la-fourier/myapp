import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/models/finance/attachment.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';

class BillEditorDialog extends StatefulWidget {
  final Bill? bill;
  final Function(Bill) onSave;

  const BillEditorDialog({super.key, this.bill, required this.onSave});

  @override
  State<BillEditorDialog> createState() => _BillEditorDialogState();
}

class _BillEditorDialogState extends State<BillEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _vendor;
  late DateTime _date;
  late Category _category;
  late List<LineItem> _items;
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _categories = appState.loggedInUser?.customCategories ?? [];

    if (widget.bill != null) {
      _vendor = widget.bill!.vendor;
      _date = widget.bill!.date;
      _category = widget.bill!.category;
      _items = List.from(widget.bill!.items);
    } else {
      _vendor = '';
      _date = DateTime.now();
      _category = _categories.isNotEmpty ? _categories.first : Category(name: 'Default', color: Colors.grey);
      _items = [LineItem(description: '', amount: 0.0)];
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newBill = Bill(
        vendor: _vendor,
        date: _date,
        category: _category,
        items: _items,
      );

      widget.onSave(newBill);
      Navigator.of(context).pop();
    }
  }

  void _addLineItem() {
    setState(() {
      _items.add(LineItem(description: '', amount: 0.0));
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bill == null ? 'Create Bill' : 'Edit Bill'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _vendor,
                decoration: const InputDecoration(labelText: 'Vendor'),
                validator: (value) => value!.isEmpty ? 'Please enter a vendor' : null,
                onSaved: (value) => _vendor = value!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text('Date: ${DateFormat.yMd().format(_date)}')),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _date) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                  ),
                ],
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
              const Divider(height: 30),
              Text('Line Items', style: Theme.of(context).textTheme.titleMedium),
              ..._items.asMap().entries.map((entry) {
                int index = entry.key;
                LineItem item = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item.description,
                        decoration: const InputDecoration(labelText: 'Description'),
                        onChanged: (value) => _items[index] = LineItem(description: value, amount: item.amount),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: item.amount.toString(),
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _items[index] = LineItem(description: item.description, amount: double.tryParse(value) ?? 0.0),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeLineItem(index),
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: _addLineItem,
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
