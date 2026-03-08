import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';

abstract class TaskItem {
  final String id;
  final String name;
  final String? description;
  final List<String> contactUids;
  final String? categoryId;
  final LatLng? location;

  TaskItem({
    required this.id,
    required this.name,
    this.description,
    List<String>? contactUids,
    this.categoryId,
    this.location,
  }) : contactUids = contactUids ?? [];

  DateTime? get deadline;
  int get priority;
  int get froggyness;
  Duration get duration;

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

  Task({
    required super.id,
    required super.name,
    super.description,
    super.contactUids,
    super.categoryId,
    super.location,
    DateTime? deadline,
    int priority = 3,
    int froggyness = 0,
    Duration duration = const Duration(minutes: 30),
  })  : _deadline = deadline,
        _priority = priority,
        _froggyness = froggyness,
        _duration = duration;

  @override
  DateTime? get deadline => _deadline;
  @override
  int get priority => _priority;
  @override
  int get froggyness => _froggyness;
  @override
  Duration get duration => _duration;

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
    );
  }
}
