import 'package:flutter/material.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';

// A wrapper class to unify Appointments and TrackedActivities for calendar display
class CalendarEvent {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final Color color;
  final dynamic
  originalEvent; // To hold the original Appointment or TrackedActivity

  CalendarEvent({
    required this.title,
    required this.startTime,
    this.endTime,
    required this.color,
    this.originalEvent,
  });

  factory CalendarEvent.fromAppointment(Appointment appointment) {
    return CalendarEvent(
      title: appointment.title,
      startTime: appointment.start,
      endTime: appointment.end,
      color: appointment.category.color,
      originalEvent: appointment,
    );
  }

  factory CalendarEvent.fromTrackedActivity(TrackedActivity activity) {
    return CalendarEvent(
      title: activity.name,
      startTime: activity.startTime,
      endTime: activity.endTime,
      color: activity.category.color,
      originalEvent: activity,
    );
  }
}
