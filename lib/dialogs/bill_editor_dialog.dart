import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

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

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

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
       if (!_categories.contains(_category)) {
        _categories.insert(0, _category);
      }
    } else {
      _vendor = '';
      _date = DateTime.now();
      _category = _categories.isNotEmpty
          ? _categories.first
          : Category(name: 'Default', color: Colors.grey);
      _items = [LineItem(description: '', amount: 0.0)];
    }
    _rawTextController.text = _billToJson();
  }

  String _billToJson() {
    final data = {
      'vendor': _vendor,
      'date': _date.toIso8601String(),
      'category': _category.toJson(),
      'items': _items.map((item) => item.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _jsonToBill(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      setState(() {
        _vendor = data['vendor'];
        _date = DateTime.parse(data['date']);
        _category = Category.fromJson(data['category']);
        _items = (data['items'] as List)
            .map((itemData) => LineItem.fromJson(itemData))
            .toList();
      });
    } catch (e) {
      // Handle JSON parsing error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
  }

  void _saveForm() {
    if (_isRawEditMode) {
      _jsonToBill(_rawTextController.text);
    }

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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.bill == null ? 'Create Bill' : 'Edit Bill'),
          IconButton(
            icon: Icon(_isRawEditMode ? Icons.notes : Icons.code),
            onPressed: () {
              setState(() {
                _isRawEditMode = !_isRawEditMode;
                if (_isRawEditMode) {
                  _rawTextController.text = _billToJson();
                } else {
                  _jsonToBill(_rawTextController.text);
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
                      initialValue: _vendor,
                      decoration: const InputDecoration(labelText: 'Vendor'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a vendor' : null,
                      onSaved: (value) => _vendor = value!,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Date:"),
                        const SizedBox(width: 10),
                        Expanded(
                          child: editable_text.EditableText(
                            initialText: DateFormat.yMd().format(_date),
                            style: Theme.of(context).textTheme.bodyLarge!,
                            onSave: (value) {
                              try {
                                final newDate = DateFormat.yMd().parse(value);
                                setState(() {
                                  _date = newDate;
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
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
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
                    const Divider(height: 20),
                    ExpansionTile(
                      title: const Text('Line Items'),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                      expansionAnimationStyle: AnimationStyle(curve: Curves.easeInOut),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      children: [
                        ..._items.asMap().entries.map((entry) {
                          int index = entry.key;
                          LineItem item = entry.value;
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.description,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                  ),
                                  onChanged: (value) => _items[index] =
                                      LineItem(
                                          description: value,
                                          amount: item.amount),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: item.amount.toString(),
                                  decoration:
                                      const InputDecoration(labelText: 'Amount'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _items[index] =
                                      LineItem(
                                          description: item.description,
                                          amount: double.tryParse(value) ?? 0.0),
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
                  ],
                ),
              ),
            ),
      actions: [
        TextButton.icon(
          onPressed: () async {
             showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
             );
             await Future.delayed(const Duration(seconds: 2));
             if (context.mounted) {
                Navigator.of(context).pop(); // close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('True AI parsing (e.g. Gemini API) would happen here!')),
                );
             }
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Use AI'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
      ],
    );
  }
}
