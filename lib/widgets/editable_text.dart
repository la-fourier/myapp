import 'package:flutter/material.dart';

class EditableText extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;
  final TextStyle style;

  const EditableText({
    super.key,
    required this.initialText,
    required this.onSave,
    this.style = const TextStyle(),
  });

  @override
  State<EditableText> createState() => _EditableTextState();
}

class _EditableTextState extends State<EditableText> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _save();
    }
  }

  void _save() {
    widget.onSave(_controller.text);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: widget.style,
        autofocus: true,
        onSubmitted: (value) => _save(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        child: Text(
          widget.initialText,
          style: widget.style,
        ),
      );
    }
  }
}