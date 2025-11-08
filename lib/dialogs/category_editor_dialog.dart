import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/widgets/editable_text.dart' as editable_text;

class CategoryEditorDialog extends StatefulWidget {
  final Category? category;

  const CategoryEditorDialog({super.key, this.category});

  @override
  State<CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<CategoryEditorDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple,
    Colors.pink, Colors.teal, Colors.indigo, Colors.amber, Colors.brown,
  ];

  bool _isRawEditMode = false;
  final TextEditingController _rawTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? 'Your new category');
    _selectedColor = widget.category?.color ?? _availableColors.first;
    _rawTextController.text = _categoryToJson();
  }

  String _categoryToJson() {
    final data = {
      'name': _nameController.text,
      'color': _selectedColor.value,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _jsonToCategory(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      setState(() {
        _nameController.text = data['name'];
        _selectedColor = Color(data['color']);
      });
    } catch (e) {
      // Handle JSON parsing error
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.category == null ? 'New Category' : 'Edit Category'),
          IconButton(
            icon: Icon(_isRawEditMode ? Icons.notes : Icons.code),
            onPressed: () {
              setState(() {
                _isRawEditMode = !_isRawEditMode;
                if (_isRawEditMode) {
                  _rawTextController.text = _categoryToJson();
                } else {
                  _jsonToCategory(_rawTextController.text);
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
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                editable_text.EditableText(
                  initialText: _nameController.text,
                  style: Theme.of(context).textTheme.titleLarge!,
                  onSave: (value) {
                    setState(() {
                      _nameController.text = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_isRawEditMode) {
              _jsonToCategory(_rawTextController.text);
            }
            if (_nameController.text.isNotEmpty) {
              final newCategory = Category(
                name: _nameController.text,
                color: _selectedColor,
              );
              Navigator.of(context).pop(newCategory);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
