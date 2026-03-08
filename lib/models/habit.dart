import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

enum HabitTimeWindow {
  morning,
  afternoon,
  evening,
  night,
  anytime;

  @override
  String toString() {
    return switch (this) {
      HabitTimeWindow.morning => 'Morning',
      HabitTimeWindow.afternoon => 'Afternoon',
      HabitTimeWindow.evening => 'Evening',
      HabitTimeWindow.night => 'Night',
      HabitTimeWindow.anytime => 'Anytime',
    };
  }
}

class Habit {
  final String id;
  final String name;
  final String? description;
  final int frequencyPerWeek; // e.g., 3 means 3 times a week
  final HabitTimeWindow preferredTimeWindow;
  final Duration minLength;
  final Duration maxLength;
  final int priority; // 0 to 5
  final int froggyness; // 0 to 5
  final List<String> contactUids;
  final String? categoryId;
  final LatLng? location;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.frequencyPerWeek = 7,
    this.preferredTimeWindow = HabitTimeWindow.anytime,
    this.minLength = const Duration(minutes: 5),
    this.maxLength = const Duration(minutes: 60),
    this.priority = 3,
    this.froggyness = 0,
    List<String>? contactUids,
    this.categoryId,
    this.location,
  }) : contactUids = contactUids ?? [];

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequencyPerWeek: json['frequencyPerWeek'] ?? 7,
      preferredTimeWindow: HabitTimeWindow.values.firstWhere(
        (e) => e.toString() == json['preferredTimeWindow'],
        orElse: () => HabitTimeWindow.anytime,
      ),
      minLength: Duration(minutes: json['minLength'] ?? 5),
      maxLength: Duration(minutes: json['maxLength'] ?? 60),
      priority: json['priority'] ?? 3,
      froggyness: json['froggyness'] ?? 0,
      contactUids: List<String>.from(json['contactUids'] ?? []),
      categoryId: json['categoryId'],
      location: json['location'] != null
          ? LatLng(json['location']['lat'], json['location']['lng'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequencyPerWeek': frequencyPerWeek,
      'preferredTimeWindow': preferredTimeWindow.toString(),
      'minLength': minLength.inMinutes,
      'maxLength': maxLength.inMinutes,
      'priority': priority,
      'froggyness': froggyness,
      'contactUids': contactUids,
      'categoryId': categoryId,
      'location': location != null
          ? {'lat': location!.latitude, 'lng': location!.longitude}
          : null,
    };
  }
}
