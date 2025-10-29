import 'package:myapp/models/calendar/appointment.dart';

class Calendar {
  final List<Appointment> appointments;

  Calendar({required this.appointments});

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      appointments: (json['appointments'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((e) => e.toJson()).toList(),
    };
  }
}
