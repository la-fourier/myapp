import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/map_location.dart';
import 'package:myapp/models/map_route.dart';

class MapService with ChangeNotifier {
  final List<MapLocation> _locations = [];
  final List<MapRoute> _routes = [];

  List<MapLocation> get locations => List.unmodifiable(_locations);
  List<MapRoute> get routes => List.unmodifiable(_routes);

  void addLocation(MapLocation location) {
    _locations.add(location);
    notifyListeners();
  }

  void removeLocation(String id) {
    _locations.removeWhere((loc) => loc.id == id);
    notifyListeners();
  }

  void addRoute(MapRoute route) {
    _routes.add(route);
    notifyListeners();
  }

  void createTour(String name, List<MapLocation> tourLocations, TransportMode mode) {
    if (tourLocations.isEmpty) return;
    
    final id = 'tour_${DateTime.now().millisecondsSinceEpoch}';
    final points = tourLocations.map((l) => l.position).toList();
    
    // In a real app, we'd fetch actual routing points from an API for the transport mode
    // For now, we use straight lines between locations
    
    final route = MapRoute(
      id: id,
      name: name,
      points: points,
      transportMode: mode,
      color: _getRouteColor(mode),
    );
    
    addRoute(route);
  }

  Color _getRouteColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking: return Colors.green;
      case TransportMode.cycling: return Colors.orange;
      case TransportMode.driving: return Colors.blue;
    }
  }

  void removeRoute(String id) {
    _routes.removeWhere((route) => route.id == id);
    notifyListeners();
  }

  void toggleRouteVisibility(String id) {
    final index = _routes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _routes[index] = _routes[index].copyWith(isVisible: !_routes[index].isVisible);
      notifyListeners();
    }
  }

  void clearAll() {
    _locations.clear();
    _routes.clear();
    notifyListeners();
  }

  // Helper to add some sample data for demonstration
  void loadSampleData() {
    clearAll();
    
    addLocation(const MapLocation(
      id: '1',
      name: 'Brandenburger Tor',
      description: 'Historisches Wahrzeichen in Berlin',
      position: LatLng(52.5163, 13.3777),
      type: MapLocationType.sight,
    ));

    addLocation(const MapLocation(
      id: '2',
      name: 'Fernsehturm',
      description: 'Aussichtsturm am Alexanderplatz',
      position: LatLng(52.5208, 13.4094),
      type: MapLocationType.sight,
    ));

    addLocation(const MapLocation(
      id: '3',
      name: 'Checkpoint Charlie',
      description: 'Ehemaliger Grenzübergang',
      position: LatLng(52.5074, 13.3904),
      type: MapLocationType.sight,
    ));

    createTour(
      'Berlin City Sightseeing (Walking)', 
      [_locations[0], _locations[2], _locations[1]], 
      TransportMode.walking
    );
  }
}
