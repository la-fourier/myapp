import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/category.dart';
import 'package:myapp/models/finance/attachment.dart';
import 'package:myapp/models/finance/bill.dart';

class Appointment {
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final Category category;
  final List<Attachment> attachments;

  Appointment({
    required this.title,
    this.description,
    required this.start,
    required this.end,
    Category? category,
    List<Attachment>? attachments,
  }) : category = category ?? Category(name: 'Default', color: Colors.blue),
       attachments = attachments ?? [];

  factory Appointment.fromJson(Map<String, dynamic> json) {
    List<Attachment> attachments = [];
    if (json['attachments'] != null) {
      for (var attachmentJson in json['attachments']) {
        if (attachmentJson['attachmentType'] == 'Bill') {
          attachments.add(Bill.fromJson(attachmentJson));
        }
        // Add other attachment types here in the future
      }
    }

    return Appointment(
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : Category(name: 'Default', color: Colors.blue),
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'category': category.toJson(),
      'attachments': attachments.map((attachment) {
        if (attachment is Bill) {
          return attachment.toJson();
        }
        // Add other attachment types here
        return {};
      }).toList(),
    };
  }
}
