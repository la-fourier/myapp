import 'package:flutter/material.dart';

class Appointment {
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final Color color;

  Appointment({
    required this.title,
    this.description,
    required this.start,
    required this.end,
    this.color = Colors.blue,
  });
}
