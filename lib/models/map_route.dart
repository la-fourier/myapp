import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum TransportMode { walking, cycling, driving }

class MapRoute {
  final String id;
  final String name;
  final List<LatLng> points;
  final Color color;
  final double strokeWidth;
  final bool isVisible;
  final TransportMode transportMode;

  const MapRoute({
    required this.id,
    required this.name,
    required this.points,
    this.color = Colors.blue,
    this.strokeWidth = 4.0,
    this.isVisible = true,
    this.transportMode = TransportMode.driving,
  });

  MapRoute copyWith({
    String? name,
    List<LatLng>? points,
    Color? color,
    double? strokeWidth,
    bool? isVisible,
    TransportMode? transportMode,
  }) {
    return MapRoute(
      id: id,
      name: name ?? this.name,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isVisible: isVisible ?? this.isVisible,
      transportMode: transportMode ?? this.transportMode,
    );
  }
}
