import 'package:latlong2/latlong.dart';

class MapLocation {
  final String id;
  final String name;
  final String? description;
  final LatLng position;
  final MapLocationType type;

  const MapLocation({
    required this.id,
    required this.name,
    this.description,
    required this.position,
    this.type = MapLocationType.place,
  });

  MapLocation copyWith({
    String? name,
    String? description,
    LatLng? position,
    MapLocationType? type,
  }) {
    return MapLocation(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      type: type ?? this.type,
    );
  }
}

enum MapLocationType {
  place,
  restaurant,
  sight,
  hotel,
  other,
}
