import 'package:flutter/material.dart';

class Category {
  final String name;
  final Color color;

  Category({required this.name, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color;

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
