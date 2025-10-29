import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/category.dart';

class Appointment {
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final Category category;

  Appointment({
    required this.title,
    this.description,
    required this.start,
    required this.end,
    Category? category,
  }) : category = category ?? Category(name: 'Default', color: Colors.blue);

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : Category(name: 'Default', color: Colors.blue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'category': category.toJson(),
    };
  }
}
