import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/task_item.dart';

class TravelTimeService {
  // Simple heuristic: 50 km/h average speed in urban areas
  static const double averageSpeedKmH = 40.0;

  double calculateDistance(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }

  Duration estimateTravelTime(LatLng p1, LatLng p2) {
    double distanceMeters = calculateDistance(p1, p2);
    double distanceKm = distanceMeters / 1000.0;
    double timeHours = distanceKm / averageSpeedKmH;
    return Duration(minutes: (timeHours * 60).round());
  }

  bool canReachOnTime(Appointment first, Appointment second) {
    if (first.location == null || second.location == null) return true;
    
    Duration travelTime = estimateTravelTime(first.location!, second.location!);
    DateTime arrivalTime = first.end.add(travelTime);
    
    return arrivalTime.isBefore(second.start);
  }

  String? getConflictMessage(Appointment first, Appointment second) {
    if (first.location == null || second.location == null) return null;
    
    Duration travelTime = estimateTravelTime(first.location!, second.location!);
    DateTime arrivalTime = first.end.add(travelTime);
    
    if (arrivalTime.isAfter(second.start)) {
      int overlapMinutes = arrivalTime.difference(second.start).inMinutes;
      return 'Warnung: Zwischen "${first.title}" und "${second.title}" fehlen ca. $overlapMinutes Minuten Reisezeit (geschätzt $travelTime).';
    }
    return null;
  }
}
