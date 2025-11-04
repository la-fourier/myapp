import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/category.dart';

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
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? _availableColors.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
            autofocus: true,
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
