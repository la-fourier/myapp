import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Represents how often something repeats.
enum FrequencyPeriod {
  day,
  week,
  month,
  year;

  @override
  String toString() {
    return switch (this) {
      FrequencyPeriod.day => 'Day',
      FrequencyPeriod.week => 'Week',
      FrequencyPeriod.month => 'Month',
      FrequencyPeriod.year => 'Year',
    };
  }
}

class Habit {
  final String id;
  final String name;
  final String? description;
  final int frequencyTimes;        // e.g. 3
  final FrequencyPeriod frequencyPeriod; // e.g. week → "3 times per week"
  final TimeOfDay? preferredStartTime;
  final TimeOfDay? preferredEndTime;
  final Duration minLength;
  final Duration maxLength;
  final int priority; // 0 to 5
  final int froggyness; // 0 to 5
  final List<String> contactUids;
  final String? categoryId;
  final LatLng? location;
  final String? address;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.frequencyTimes = 7,
    this.frequencyPeriod = FrequencyPeriod.week,
    this.preferredStartTime,
    this.preferredEndTime,
    this.minLength = const Duration(minutes: 5),
    this.maxLength = const Duration(minutes: 60),
    this.priority = 3,
    this.froggyness = 0,
    List<String>? contactUids,
    this.categoryId,
    this.location,
    this.address,
  }) : contactUids = contactUids ?? [];

  /// Helper for backward compat: convert from old frequencyPerWeek
  int get frequencyPerWeek {
    switch (frequencyPeriod) {
      case FrequencyPeriod.day:
        return frequencyTimes * 7;
      case FrequencyPeriod.week:
        return frequencyTimes;
      case FrequencyPeriod.month:
        return (frequencyTimes / 4.3).round().clamp(1, 35);
      case FrequencyPeriod.year:
        return (frequencyTimes / 52).round().clamp(1, 35);
    }
  }

  String get frequencyLabel => '$frequencyTimes × per ${frequencyPeriod.toString()}';

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequencyTimes: json['frequencyTimes'] ?? json['frequencyPerWeek'] ?? 7,
      frequencyPeriod: FrequencyPeriod.values.firstWhere(
        (e) => e.toString() == json['frequencyPeriod'],
        orElse: () => FrequencyPeriod.week,
      ),
      preferredStartTime: json['preferredStartHour'] != null
          ? TimeOfDay(hour: json['preferredStartHour'], minute: json['preferredStartMinute'] ?? 0)
          : null,
      preferredEndTime: json['preferredEndHour'] != null
          ? TimeOfDay(hour: json['preferredEndHour'], minute: json['preferredEndMinute'] ?? 0)
          : null,
      minLength: Duration(minutes: json['minLength'] ?? 5),
      maxLength: Duration(minutes: json['maxLength'] ?? 60),
      priority: json['priority'] ?? 3,
      froggyness: json['froggyness'] ?? 0,
      contactUids: List<String>.from(json['contactUids'] ?? []),
      categoryId: json['categoryId'],
      location: json['location'] != null
          ? LatLng(json['location']['lat'], json['location']['lng'])
          : null,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequencyTimes': frequencyTimes,
      'frequencyPeriod': frequencyPeriod.toString(),
      'preferredStartHour': preferredStartTime?.hour,
      'preferredStartMinute': preferredStartTime?.minute,
      'preferredEndHour': preferredEndTime?.hour,
      'preferredEndMinute': preferredEndTime?.minute,
      'minLength': minLength.inMinutes,
      'maxLength': maxLength.inMinutes,
      'priority': priority,
      'froggyness': froggyness,
      'contactUids': contactUids,
      'categoryId': categoryId,
      'location': location != null
          ? {'lat': location!.latitude, 'lng': location!.longitude}
          : null,
      'address': address,
    };
  }
}
