import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';

abstract class TaskItem {
  final String id;
  final String name;
  final String? description;
  final List<String> contactUids;
  final String? categoryId;
  final LatLng? location;
  final String? address;

  TaskItem({
    required this.id,
    required this.name,
    this.description,
    List<String>? contactUids,
    this.categoryId,
    this.location,
    this.address,
  }) : contactUids = contactUids ?? [];

  DateTime? get deadline;
  int get priority;
  int get froggyness;
  Duration get duration;
  double get progress;

  Map<String, dynamic> toJson();

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'Project') {
      return Project.fromJson(json);
    } else {
      return Task.fromJson(json);
    }
  }
}

class Task extends TaskItem {
  final DateTime? _deadline;
  final int _priority;
  final int _froggyness;
  final Duration _duration;
  final List<String> sessionIds; // references TrackedActivity ids

  Task({
    required super.id,
    required super.name,
    super.description,
    super.contactUids,
    super.categoryId,
    super.location,
    super.address,
    DateTime? deadline,
    int priority = 3,
    int froggyness = 0,
    Duration duration = const Duration(minutes: 30),
    List<String>? sessionIds,
  })  : _deadline = deadline,
        _priority = priority,
        _froggyness = froggyness,
        _duration = duration,
        sessionIds = sessionIds ?? [];

  @override
  DateTime? get deadline => _deadline;
  @override
  int get priority => _priority;
  @override
  int get froggyness => _froggyness;
  @override
  Duration get duration => _duration;

  /// Progress is computed externally by comparing session durations to _duration.
  /// This getter returns 0 here; the view layer computes actual progress
  /// by summing TrackedActivity durations matching sessionIds.
  @override
  double get progress => 0.0; // placeholder – computed in view layer

  /// Compute progress given actual worked duration.
  double computeProgress(Duration workedDuration) {
    if (_duration.inMinutes <= 0) return 1.0;
    return (workedDuration.inMinutes / _duration.inMinutes).clamp(0.0, 1.0);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'Task',
      'id': id,
      'name': name,
      'description': description,
      'contactUids': contactUids,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'froggyness': froggyness,
      'duration': duration.inMinutes,
      'categoryId': categoryId,
      'location': location != null
          ? {'lat': location!.latitude, 'lng': location!.longitude}
          : null,
      'address': address,
      'sessionIds': sessionIds,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      contactUids: List<String>.from(json['contactUids'] ?? []),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      priority: json['priority'] ?? 3,
      froggyness: json['froggyness'] ?? 0,
      duration: Duration(minutes: json['duration'] ?? 30),
      categoryId: json['categoryId'],
      location: json['location'] != null
          ? LatLng(json['location']['lat'], json['location']['lng'])
          : null,
      address: json['address'],
      sessionIds: List<String>.from(json['sessionIds'] ?? []),
    );
  }
}

class Project extends TaskItem {
  final List<TaskItem> children;

  Project({
    required super.id,
    required super.name,
    super.description,
    super.contactUids,
    super.categoryId,
    super.location,
    super.address,
    List<TaskItem>? children,
  }) : children = children ?? [];

  @override
  DateTime? get deadline {
    if (children.isEmpty) return null;
    return children
        .map((e) => e.deadline)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (max, e) => (max == null || e.isAfter(max)) ? e : max);
  }

  @override
  int get priority {
    if (children.isEmpty) return 3;
    final sum = children.map((e) => e.priority).sum;
    return (sum / children.length).round();
  }

  @override
  int get froggyness {
    if (children.isEmpty) return 0;
    final sum = children.map((e) => e.froggyness).sum;
    return (sum / children.length).round();
  }

  @override
  Duration get duration {
    if (children.isEmpty) return Duration.zero;
    return children.map((e) => e.duration).fold(Duration.zero, (sum, e) => sum + e);
  }

  @override
  double get progress {
    if (children.isEmpty) return 0.0;
    final total = children.map((e) => e.progress).sum;
    return total / children.length;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'Project',
      'id': id,
      'name': name,
      'description': description,
      'contactUids': contactUids,
      'children': children.map((e) => e.toJson()).toList(),
      'categoryId': categoryId,
      'location': location != null
          ? {'lat': location!.latitude, 'lng': location!.longitude}
          : null,
      'address': address,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      contactUids: List<String>.from(json['contactUids'] ?? []),
      children: (json['children'] as List? ?? [])
          .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      categoryId: json['categoryId'],
      location: json['location'] != null
          ? LatLng(json['location']['lat'], json['location']['lng'])
          : null,
      address: json['address'],
    );
  }
}
