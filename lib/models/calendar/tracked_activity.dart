import 'package:myapp/models/calendar/category.dart';

class TrackedActivity {
  final String id;
  final String name;
  final Category category;
  final DateTime startTime;
  final DateTime endTime;

  TrackedActivity({
    String? id,
    required this.name,
    required this.category,
    required this.startTime,
    required this.endTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory TrackedActivity.fromJson(Map<String, dynamic> json) {
    return TrackedActivity(
      id: json['id'],
      name: json['name'],
      category: Category.fromJson(json['category']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
