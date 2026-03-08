import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/calendar/tracked_activity.dart';

class Calendar {
  final List<Appointment> appointments;
  final List<TrackedActivity> trackedActivities;

  Calendar({required this.appointments, List<TrackedActivity>? trackedActivities})
      : trackedActivities = trackedActivities ?? [];

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      appointments: (json['appointments'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList(),
      trackedActivities: json['trackedActivities'] != null
          ? (json['trackedActivities'] as List)
                .map((e) => TrackedActivity.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((e) => e.toJson()).toList(),
      'trackedActivities': trackedActivities.map((e) => e.toJson()).toList(),
    };
  }
}
