import 'package:myapp/models/calendar/appointment.dart';

class AppointmentFormat {
  final String name;
  final Duration duration;
  final Priority priority;

  AppointmentFormat({
    required this.name,
    required this.duration,
    this.priority = Priority.normal,
  });

  Appointment toAppointment({required DateTime start}) {
    return Appointment(
      title: name,
      start: start,
      end: start.add(duration),
      priority: priority,
    );
  }
}
